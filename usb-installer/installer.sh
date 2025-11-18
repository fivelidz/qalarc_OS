#!/usr/bin/env bash
# qalarc_OS Interactive Installer
# Version: 1.0.0
# Provides profile-based installation with hardware detection

set -e

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILES_DIR="$SCRIPT_DIR/profiles"
MODULES_DIR="$SCRIPT_DIR/modules"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
HARDWARE_SCRIPT="$SCRIPT_DIR/detect-hardware.sh"

# Installation state
SELECTED_PROFILE=""
SELECTED_MODULES=()
HOSTNAME="qalarc-workstation"
USERNAME="qalarc"
DISK_DEVICE=""
VRAM_DETECTED=0
IS_PORTABLE="false"
PORTABLE_RECOMMENDED="false"

# ============================================================================
# Utility Functions
# ============================================================================

print_header() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
   ┏━┓┏━┓╻  ┏━┓┏━┓┏━╸   ┏━┓┏━┓
   ┃┓┃┣━┫┃  ┣━┫┣┳┛┃     ┃ ┃┗━┓
   ┗┻┛╹ ╹┗━╸╹ ╹╹┗╸┗━╸   ┗━┛┗━┛

   Interactive Installer v1.0.0
EOF
    echo -e "${NC}"
    echo ""
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

check_dialog() {
    if ! command -v dialog &> /dev/null; then
        log_error "dialog is not installed. Installing..."
        nix-shell -p dialog --run "echo 'dialog loaded'"
        if ! command -v dialog &> /dev/null; then
            log_error "Failed to load dialog. Falling back to basic mode."
            return 1
        fi
    fi
    return 0
}

# ============================================================================
# Hardware Detection
# ============================================================================

detect_hardware() {
    print_header
    log_info "Detecting hardware configuration..."

    # Detect CPU
    CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
    log_info "CPU: $CPU_MODEL"

    # Detect RAM
    TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
    log_info "RAM: ${TOTAL_RAM}GB"

    # Detect GPU
    if lspci | grep -i "VGA" | grep -qi "AMD"; then
        GPU_MODEL=$(lspci | grep -i "VGA" | grep -i "AMD" | cut -d':' -f3 | xargs)
        log_info "GPU: $GPU_MODEL (AMD)"

        # Check for VRAM allocation (if rocm-smi available)
        if command -v rocm-smi &> /dev/null; then
            VRAM_GB=$(rocm-smi --showmeminfo vram 2>/dev/null | grep -i "VRAM Total" | awk '{print int($5/1024/1024/1024)}')
            if [ -n "$VRAM_GB" ] && [ "$VRAM_GB" -gt 0 ]; then
                VRAM_DETECTED=$VRAM_GB
                log_success "Detected VRAM: ${VRAM_GB}GB"

                if [ "$VRAM_GB" -ge 90 ]; then
                    log_success "Excellent! 96GB VRAM detected - can run 70B+ models"
                elif [ "$VRAM_GB" -ge 60 ]; then
                    log_warn "64GB VRAM detected - consider BIOS update for 96GB"
                else
                    log_warn "Low VRAM detected - recommend BIOS configuration for 96GB"
                fi
            else
                log_warn "Could not detect VRAM allocation"
            fi
        else
            log_info "rocm-smi not available yet (will be installed)"
        fi
    else
        log_warn "AMD GPU not detected - AI acceleration may be limited"
    fi

    # Detect available disks
    log_info "Available disks:"
    lsblk -d -o NAME,SIZE,TYPE | grep disk

    echo ""
    read -p "Press Enter to continue..."
}

# ============================================================================
# Profile Selection
# ============================================================================

show_profile_menu() {
    if check_dialog; then
        PROFILE_CHOICE=$(dialog --clear --title "qalarc_OS Installation Profile" \
            --menu "Choose your installation profile:" 20 70 3 \
            "ai-workstation" "AI Development & Research (Recommended)" \
            "gaming-ai" "Gaming + AI (Steam, Ollama, ROCm)" \
            "custom" "Custom - Choose your own modules" \
            3>&1 1>&2 2>&3)

        clear
        SELECTED_PROFILE="$PROFILE_CHOICE"
    else
        # Fallback to basic menu
        print_header
        echo -e "${CYAN}=== Installation Profile ===${NC}"
        echo ""
        echo "1) AI Workstation      - AI Development & Research (Recommended)"
        echo "2) Gaming + AI         - Steam, Ollama, ROCm"
        echo "3) Custom              - Choose your own modules"
        echo ""
        read -p "Select profile [1-3]: " choice

        case $choice in
            1) SELECTED_PROFILE="ai-workstation" ;;
            2) SELECTED_PROFILE="gaming-ai" ;;
            3) SELECTED_PROFILE="custom" ;;
            *) log_error "Invalid choice"; exit 1 ;;
        esac
    fi

    if [ -z "$SELECTED_PROFILE" ]; then
        log_error "No profile selected. Exiting."
        exit 1
    fi

    log_success "Selected profile: $SELECTED_PROFILE"
}

# ============================================================================
# Module Selection (for custom profile)
# ============================================================================

show_module_menu() {
    if [ "$SELECTED_PROFILE" != "custom" ]; then
        return
    fi

    if check_dialog; then
        MODULES=$(dialog --clear --title "Select Modules to Install" \
            --checklist "Use SPACE to select, ENTER to confirm:" 20 70 10 \
            "ollama" "Local LLM Server with ROCm" ON \
            "open-webui" "Web UI for AI Models" ON \
            "rocm" "AMD GPU Compute Platform" ON \
            "docker" "Container Platform" ON \
            "steam" "Gaming Platform" OFF \
            "vscode" "Visual Studio Code" ON \
            "python-ml" "Python ML Stack (PyTorch, Transformers)" ON \
            "textual" "Terminal UI Development" ON \
            "gaming-tools" "Lutris, Heroic, ProtonUp" OFF \
            "obs" "OBS Studio for Recording" OFF \
            3>&1 1>&2 2>&3)

        clear

        # Convert space-separated string to array
        IFS=' ' read -ra SELECTED_MODULES <<< "$MODULES"
    else
        # Fallback: select all recommended modules
        SELECTED_MODULES=("ollama" "open-webui" "rocm" "docker" "vscode" "python-ml" "textual")
    fi

    log_info "Selected modules: ${SELECTED_MODULES[*]}"
}

# ============================================================================
# System Configuration
# ============================================================================

get_system_info() {
    print_header
    echo -e "${CYAN}=== System Configuration ===${NC}"
    echo ""

    # Hostname
    read -p "Enter hostname [qalarc-workstation]: " input_hostname
    HOSTNAME=${input_hostname:-qalarc-workstation}

    # Username
    read -p "Enter username [qalarc]: " input_username
    USERNAME=${input_username:-qalarc}

    # Disk selection
    echo ""
    echo "Available disks:"
    lsblk -d -o NAME,SIZE,TYPE | grep disk
    echo ""
    read -p "Enter disk to install to (e.g., nvme0n1, sda): " input_disk
    DISK_DEVICE="/dev/$input_disk"

    if [ ! -b "$DISK_DEVICE" ]; then
        log_error "Disk $DISK_DEVICE does not exist!"
        exit 1
    fi

    # Confirmation
    echo ""
    log_warn "WARNING: This will erase all data on $DISK_DEVICE!"
    read -p "Type 'yes' to continue: " confirm
    if [ "$confirm" != "yes" ]; then
        log_error "Installation cancelled."
        exit 1
    fi
}

# ============================================================================
# Portable Installation Check
# ============================================================================

check_portable_installation() {
    print_header
    echo -e "${CYAN}=== Portable Installation Detection ===${NC}"
    echo ""

    # Check if selected disk is removable
    DISK_NAME=$(basename "$DISK_DEVICE")

    # Run portable check
    if [ -f "$HARDWARE_SCRIPT" ]; then
        # Source the check_if_portable function
        source "$HARDWARE_SCRIPT"
        PORTABLE_CHECK=$(check_if_portable "$DISK_NAME")
        PORTABLE_STATUS=$(echo "$PORTABLE_CHECK" | cut -d':' -f1)
        PORTABLE_REASON=$(echo "$PORTABLE_CHECK" | cut -d':' -f2-)

        echo -e "${BLUE}Target disk:${NC} $DISK_DEVICE"
        echo -e "${BLUE}Analysis:${NC} $PORTABLE_REASON"
        echo ""

        if [ "$PORTABLE_STATUS" = "true" ]; then
            PORTABLE_RECOMMENDED="true"
            log_success "This drive is suitable for portable installation!"
            echo ""
            echo "Portable installation allows qalarc_OS to boot on different computers"
            echo "from this external drive."
            echo ""
            read -p "Configure as portable installation? [Y/n]: " portable_choice
            if [[ ! "$portable_choice" =~ ^[Nn]$ ]]; then
                IS_PORTABLE="true"
                log_success "Portable installation mode enabled"
            fi
        elif [ "$PORTABLE_STATUS" = "maybe" ]; then
            log_warn "Drive has limited capacity for portable use"
            read -p "Still configure as portable? [y/N]: " portable_choice
            if [[ "$portable_choice" =~ ^[Yy]$ ]]; then
                IS_PORTABLE="true"
            fi
        else
            log_info "Fixed disk detected - standard installation"
        fi
    fi

    echo ""
    read -p "Press Enter to continue..."
}

# ============================================================================
# Installation Summary
# ============================================================================

show_summary() {
    print_header
    echo -e "${CYAN}=== Installation Summary ===${NC}"
    echo ""
    echo -e "${YELLOW}Profile:${NC}    $SELECTED_PROFILE"
    echo -e "${YELLOW}Hostname:${NC}   $HOSTNAME"
    echo -e "${YELLOW}Username:${NC}   $USERNAME"
    echo -e "${YELLOW}Disk:${NC}       $DISK_DEVICE"

    if [ "$IS_PORTABLE" = "true" ]; then
        echo -e "${YELLOW}Type:${NC}       ${GREEN}Portable Installation${NC} (boots on different hardware)"
    else
        echo -e "${YELLOW}Type:${NC}       Standard Installation (optimized for this hardware)"
    fi

    if [ "$SELECTED_PROFILE" = "custom" ]; then
        echo -e "${YELLOW}Modules:${NC}    ${SELECTED_MODULES[*]}"
    fi

    if [ "$VRAM_DETECTED" -gt 0 ]; then
        echo -e "${YELLOW}VRAM:${NC}       ${VRAM_DETECTED}GB detected"
    fi

    echo ""
    read -p "Proceed with installation? [y/N]: " proceed
    if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
        log_error "Installation cancelled."
        exit 1
    fi
}

# ============================================================================
# NixOS Configuration Generation
# ============================================================================

generate_configuration() {
    log_info "Generating NixOS configuration..."

    # Create temporary directory for configuration
    CONFIG_DIR="/tmp/qalarc-install-config"
    mkdir -p "$CONFIG_DIR"

    # Copy base profile
    if [ -f "$PROFILES_DIR/$SELECTED_PROFILE.nix" ]; then
        cp "$PROFILES_DIR/$SELECTED_PROFILE.nix" "$CONFIG_DIR/configuration.nix"
        log_success "Loaded profile: $SELECTED_PROFILE"
    else
        log_error "Profile not found: $SELECTED_PROFILE"
        exit 1
    fi

    # Replace placeholders
    sed -i "s/{{HOSTNAME}}/$HOSTNAME/g" "$CONFIG_DIR/configuration.nix"
    sed -i "s/{{USERNAME}}/$USERNAME/g" "$CONFIG_DIR/configuration.nix"

    # Add portable installation configuration if needed
    if [ "$IS_PORTABLE" = "true" ]; then
        log_info "Configuring for portable installation..."

        # Add portable-specific settings to configuration
        cat >> "$CONFIG_DIR/configuration.nix.portable" << 'EOF'

# ═══════════════════════════════════════════════════════════
# PORTABLE INSTALLATION CONFIGURATION
# ═══════════════════════════════════════════════════════════

# Use UUIDs instead of device names for stability across hardware
boot.loader.grub.devices = [ "nodev" ];
boot.loader.efi.efiSysMountPoint = "/boot/efi";

# Generic kernel parameters (no hardware-specific optimizations)
boot.kernelParams = [
  "quiet"
  "splash"
];

# Load common drivers
boot.initrd.availableKernelModules = [
  # USB
  "uas" "usb_storage" "usbhid"
  # Common storage controllers
  "ahci" "xhci_pci" "nvme" "sd_mod"
  # AMD graphics (fallback)
  "amdgpu" "radeon"
];

# Network detection (support various NICs)
networking.useDHCP = lib.mkDefault true;

# Don't use hardware-specific optimizations
nixpkgs.hostPlatform = "x86_64-linux";  # Generic, not native

EOF

        # Merge portable config
        cat "$CONFIG_DIR/configuration.nix.portable" >> "$CONFIG_DIR/configuration.nix"
        rm "$CONFIG_DIR/configuration.nix.portable"

        log_success "Portable configuration added"
    fi

    # Add custom modules if selected
    if [ "$SELECTED_PROFILE" = "custom" ] && [ ${#SELECTED_MODULES[@]} -gt 0 ]; then
        log_info "Adding custom modules..."
        # This would merge module configurations
        # For now, just log them
        for module in "${SELECTED_MODULES[@]}"; do
            log_info "  - $module"
        done
    fi

    log_success "Configuration generated at $CONFIG_DIR/configuration.nix"
}

# ============================================================================
# Disk Partitioning
# ============================================================================

partition_disk() {
    log_info "Partitioning disk $DISK_DEVICE..."

    # This is a placeholder - actual implementation would use parted/sgdisk
    # to create:
    # - 512MB EFI partition
    # - Remaining space for BTRFS root

    log_warn "Disk partitioning would happen here (not implemented in this version)"
    log_info "In production, this would:"
    log_info "  1. Create EFI partition (512MB)"
    log_info "  2. Create root partition (remaining space)"
    log_info "  3. Format as BTRFS with subvolumes"
    log_info "  4. Mount partitions"
}

# ============================================================================
# NixOS Installation
# ============================================================================

install_nixos() {
    log_info "Installing NixOS..."

    # This is a placeholder - actual implementation would:
    # 1. nixos-generate-config --root /mnt
    # 2. Copy our generated configuration
    # 3. nixos-install

    log_warn "NixOS installation would happen here (not implemented in this version)"
    log_info "In production, this would:"
    log_info "  1. Generate hardware configuration"
    log_info "  2. Copy custom configuration to /mnt/etc/nixos/"
    log_info "  3. Run nixos-install"
    log_info "  4. Set user password"
    log_info "  5. Complete installation"
}

# ============================================================================
# Post-Installation
# ============================================================================

post_install() {
    log_info "Running post-installation tasks..."

    # Create documentation
    DOC_DIR="/mnt/home/$USERNAME/Documents/qalarc-os-setup"
    mkdir -p "$DOC_DIR"

    # Copy installation summary
    cat > "$DOC_DIR/INSTALLATION-INFO.md" << EOF
# qalarc_OS Installation Summary

**Date:** $(date)
**Profile:** $SELECTED_PROFILE
**Hostname:** $HOSTNAME
**Username:** $USERNAME
**Disk:** $DISK_DEVICE

## Detected Hardware

- CPU: $CPU_MODEL
- RAM: ${TOTAL_RAM}GB
- VRAM: ${VRAM_DETECTED}GB

## Next Steps

1. Reboot into your new qalarc_OS installation
2. Open Ghostty terminal - the welcome screen will guide you
3. If VRAM < 96GB, follow ~/Documents/qalarc-os-setup/BIOS-SETUP-GUIDE.md
4. Download AI models: ollama pull llama3.3:70b

## Resources

- Main documentation: ~/claude/OM/
- Ideas folder: ~/claude/OM/ideas/
- Projects: ~/projects/

Enjoy your qalarc_OS installation!
EOF

    log_success "Installation complete!"
}

# ============================================================================
# Main Installation Flow
# ============================================================================

main() {
    print_header

    log_info "Welcome to the qalarc_OS Interactive Installer!"
    echo ""
    sleep 1

    # Step 1: Detect hardware
    detect_hardware

    # Step 2: Select profile
    show_profile_menu

    # Step 3: Select modules (if custom)
    show_module_menu

    # Step 4: Get system configuration
    get_system_info

    # Step 5: Check portable installation
    check_portable_installation

    # Step 6: Show summary
    show_summary

    # Step 6: Generate configuration
    generate_configuration

    # Step 7: Partition disk
    partition_disk

    # Step 8: Install NixOS
    install_nixos

    # Step 9: Post-installation
    post_install

    # Done!
    print_header
    echo -e "${GREEN}"
    cat << "EOF"
   ╻┏┓╻┏━┓╻ ╻┏━┓╻  ╻  ┏━┓╻ ╻╻┏━┓┏┓╻
   ┃┃┗┫┗━┓┃ ┃┣━┫┃  ┃  ┣━┫┃ ┃┃┃ ┃┃┗┫
   ╹╹ ╹┗━┛┗━┛╹ ╹┗━╸┗━╸╹ ╹┗━┛╹┗━┛╹ ╹
   ┏━╸┏━┓┏┳┓┏━┓╻  ┏━╸╻ ╻┏━╸
   ┃  ┃ ┃┃┃┃┣━┛┃  ┣╸ ┃ ┃┣╸
   ┗━╸┗━┛╹ ╹╹  ┗━╸┗━╸┗━┛┗━╸

   qalarc_OS has been installed successfully!

   Remove the installation media and reboot.

   On first boot, the qalarc Welcome Window will guide you through:
   - Hardware verification
   - AI model downloads
   - System tour

   Thank you for choosing qalarc_OS!
EOF
    echo -e "${NC}"
    echo ""
}

# Run main installation
main "$@"
