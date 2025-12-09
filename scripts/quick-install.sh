#!/usr/bin/env bash
#
# quick-install.sh
# Automated qalarc_OS installer with guided prompts
#
# Usage: ./quick-install.sh
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_step() { echo -e "\n${CYAN}${BOLD}=== $1 ===${NC}\n"; }

# Configuration variables (set during prompts)
TARGET_DISK=""
USE_ENCRYPTION="yes"
USERNAME="qalarc"
HOSTNAME="gmktec-01"
INSTALL_TYPE="single-drive"  # single-drive or dual-drive
QALARC_OS_PATH="/etc/qalarc_OS"

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root"
        log_info "Run: sudo ./quick-install.sh"
        exit 1
    fi
}

# Show welcome banner
show_welcome() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔════════════════════════════════════════════════════════════════╗
    ║                                                                ║
    ║              qalarc_OS Quick Installer v1.0                    ║
    ║              NixOS for AMD Ryzen AI Max+ 395                   ║
    ║                                                                ║
    ╠════════════════════════════════════════════════════════════════╣
    ║                                                                ║
    ║  This installer will guide you through setting up qalarc_OS   ║
    ║  with optimized settings for AI/ML workloads.                 ║
    ║                                                                ║
    ║  Features:                                                     ║
    ║   • BTRFS with snapshots and compression                      ║
    ║   • Optional LUKS encryption                                   ║
    ║   • 96GB UMA VRAM support                                      ║
    ║   • Pre-configured for Ollama and ROCm                        ║
    ║                                                                ║
    ╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo ""
    read -p "Press Enter to continue or Ctrl+C to exit..."
}

# Check network connectivity
check_network() {
    log_step "Checking Network Connectivity"

    if ping -c 1 -W 3 nixos.org &>/dev/null; then
        log_success "Network connection verified"
        return 0
    else
        log_warn "No network connection detected"
        echo ""
        echo "Connect to WiFi using: nmtui"
        echo "Or plug in Ethernet cable"
        echo ""
        read -p "Press Enter after connecting to network..."

        if ping -c 1 -W 3 nixos.org &>/dev/null; then
            log_success "Network connection verified"
            return 0
        else
            log_error "Still no network. Cannot proceed without internet."
            exit 1
        fi
    fi
}

# Detect and select target disk
select_disk() {
    log_step "Disk Selection"

    echo "Available disks:"
    echo ""
    lsblk -d -o NAME,SIZE,MODEL,TYPE | grep -E "disk|NAME"
    echo ""

    # Find NVMe drives
    NVME_DRIVES=$(lsblk -d -n -o NAME,TYPE | grep disk | awk '{print $1}' | grep -E "nvme|sd")

    if [ -z "$NVME_DRIVES" ]; then
        log_error "No drives detected!"
        exit 1
    fi

    # Count drives
    DRIVE_COUNT=$(echo "$NVME_DRIVES" | wc -l)

    echo "Detected drives: $DRIVE_COUNT"
    echo ""

    # Prompt for target disk
    echo "Enter the disk to install qalarc_OS on:"
    echo "(This will ERASE ALL DATA on the selected disk!)"
    echo ""

    PS3="Select disk number: "
    select disk in $NVME_DRIVES "Cancel"; do
        case $disk in
            "Cancel")
                log_info "Installation cancelled"
                exit 0
                ;;
            *)
                if [ -n "$disk" ]; then
                    TARGET_DISK="/dev/$disk"
                    break
                fi
                ;;
        esac
    done

    echo ""
    log_warn "Selected disk: $TARGET_DISK"
    lsblk "$TARGET_DISK" -o NAME,SIZE,TYPE,MOUNTPOINT
    echo ""

    read -p "Are you SURE you want to erase $TARGET_DISK? (type 'yes' to confirm): " confirm
    if [ "$confirm" != "yes" ]; then
        log_error "Aborted"
        exit 1
    fi

    log_success "Disk selected: $TARGET_DISK"
}

# Prompt for configuration options
configure_options() {
    log_step "Installation Options"

    # Encryption
    echo "LUKS Encryption provides security for your data at rest."
    echo "Recommended for laptops and portable devices."
    echo ""
    read -p "Enable LUKS encryption? (Y/n): " enc_choice
    case $enc_choice in
        [Nn]*)
            USE_ENCRYPTION="no"
            log_info "Encryption: Disabled"
            ;;
        *)
            USE_ENCRYPTION="yes"
            log_info "Encryption: Enabled"
            ;;
    esac
    echo ""

    # Username
    echo "Enter username for the main user account:"
    read -p "Username (default: qalarc): " user_input
    if [ -n "$user_input" ]; then
        # Validate username
        if [[ "$user_input" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
            USERNAME="$user_input"
        else
            log_warn "Invalid username. Using default: qalarc"
            USERNAME="qalarc"
        fi
    fi
    log_info "Username: $USERNAME"
    echo ""

    # Hostname
    echo "Enter hostname for this machine:"
    read -p "Hostname (default: gmktec-01): " host_input
    if [ -n "$host_input" ]; then
        HOSTNAME="$host_input"
    fi
    log_info "Hostname: $HOSTNAME"
    echo ""

    # Install type based on drive count
    NVME_COUNT=$(lsblk -d -n -o NAME,TYPE | grep disk | grep nvme | wc -l)
    if [ "$NVME_COUNT" -ge 2 ]; then
        echo "Multiple NVMe drives detected."
        echo "  1) Single drive - Everything on $TARGET_DISK"
        echo "  2) Dual drive - System on $TARGET_DISK, AI models on second drive"
        echo ""
        read -p "Select layout (1 or 2, default: 1): " layout_choice
        case $layout_choice in
            2)
                INSTALL_TYPE="dual-drive"
                log_info "Install type: Dual drive"
                ;;
            *)
                INSTALL_TYPE="single-drive"
                log_info "Install type: Single drive"
                ;;
        esac
    else
        INSTALL_TYPE="single-drive"
        log_info "Install type: Single drive (only one drive detected)"
    fi

    # Summary
    log_step "Configuration Summary"
    echo "  Target disk:    $TARGET_DISK"
    echo "  Encryption:     $USE_ENCRYPTION"
    echo "  Username:       $USERNAME"
    echo "  Hostname:       $HOSTNAME"
    echo "  Install type:   $INSTALL_TYPE"
    echo ""
    read -p "Proceed with installation? (Y/n): " proceed
    case $proceed in
        [Nn]*)
            log_error "Installation cancelled"
            exit 0
            ;;
    esac
}

# Unmount any existing partitions on target disk
unmount_disk() {
    log_info "Cleaning up existing partitions and encryption..."

    # Unmount any mounted partitions from target disk
    for part in ${TARGET_DISK}*; do
        if mountpoint -q "$part" 2>/dev/null || mount | grep -q "$part"; then
            umount -f "$part" 2>/dev/null || true
        fi
    done

    # Also unmount /mnt if it's in use
    umount -R /mnt 2>/dev/null || true

    # Close ALL dm-crypt/LUKS devices (be thorough)
    for mapper in /dev/mapper/*; do
        name=$(basename "$mapper")
        if [ "$name" != "control" ]; then
            cryptsetup close "$name" 2>/dev/null || true
            dmsetup remove "$name" 2>/dev/null || true
        fi
    done

    # Wipe any existing LUKS headers on partitions
    for part in ${TARGET_DISK}p2 ${TARGET_DISK}2; do
        if [ -b "$part" ]; then
            log_info "Wiping LUKS header on $part..."
            cryptsetup erase "$part" 2>/dev/null || true
            wipefs -a "$part" 2>/dev/null || true
        fi
    done

    # Give kernel time to update
    sleep 1
    log_success "Cleanup complete"
}

# Partition the disk
partition_disk() {
    log_step "Partitioning Disk"

    unmount_disk

    log_info "Creating GPT partition table on $TARGET_DISK..."

    # Use sgdisk for scripted partitioning
    sgdisk --zap-all "$TARGET_DISK"

    # Create EFI partition (2GB)
    sgdisk -n 1:0:+2G -t 1:ef00 -c 1:"EFI" "$TARGET_DISK"

    # Create root partition (remaining space)
    sgdisk -n 2:0:0 -t 2:8300 -c 2:"NixOS" "$TARGET_DISK"

    # Ensure kernel sees new partitions
    partprobe "$TARGET_DISK"
    sleep 2

    log_success "Partitions created"
    lsblk "$TARGET_DISK" -o NAME,SIZE,TYPE,PARTLABEL
}

# Get partition paths (handles nvme naming)
get_partition_path() {
    local disk=$1
    local num=$2

    if [[ "$disk" == *"nvme"* ]]; then
        echo "${disk}p${num}"
    else
        echo "${disk}${num}"
    fi
}

# Setup encryption (if enabled)
setup_encryption() {
    local root_part=$(get_partition_path "$TARGET_DISK" 2)

    if [ "$USE_ENCRYPTION" = "yes" ]; then
        log_step "Setting Up LUKS Encryption"

        log_warn "You will be asked to set an encryption password."
        log_warn "REMEMBER THIS PASSWORD - it's required to boot!"
        echo ""

        cryptsetup luksFormat --type luks2 "$root_part"

        log_info "Opening encrypted partition..."
        cryptsetup luksOpen "$root_part" cryptroot

        ROOT_DEVICE="/dev/mapper/cryptroot"
        log_success "Encryption configured"
    else
        ROOT_DEVICE="$root_part"
        log_info "Skipping encryption (not enabled)"
    fi
}

# Format partitions
format_partitions() {
    log_step "Formatting Partitions"

    local efi_part=$(get_partition_path "$TARGET_DISK" 2)
    efi_part=$(get_partition_path "$TARGET_DISK" 1)

    log_info "Formatting EFI partition (FAT32)..."
    mkfs.fat -F 32 -n BOOT "$efi_part"
    log_success "EFI partition formatted"

    log_info "Formatting root partition (BTRFS)..."
    mkfs.btrfs -f -L nixos "$ROOT_DEVICE"
    log_success "Root partition formatted"
}

# Create BTRFS subvolumes
create_subvolumes() {
    log_step "Creating BTRFS Subvolumes"

    log_info "Mounting root filesystem..."
    mount "$ROOT_DEVICE" /mnt

    cd /mnt

    log_info "Creating subvolumes..."
    btrfs subvolume create @
    btrfs subvolume create @home
    btrfs subvolume create @nix
    btrfs subvolume create @local-llms
    btrfs subvolume create @context
    btrfs subvolume create @snapshots
    btrfs subvolume create @var-log

    cd /
    umount /mnt

    log_success "Subvolumes created: @, @home, @nix, @local-llms, @context, @snapshots, @var-log"
}

# Mount all filesystems
mount_filesystems() {
    log_step "Mounting Filesystems"

    local efi_part=$(get_partition_path "$TARGET_DISK" 1)

    # Mount root subvolume
    log_info "Mounting root subvolume..."
    mount -o subvol=@,compress=zstd:3,noatime "$ROOT_DEVICE" /mnt

    # Create mount points
    mkdir -p /mnt/{boot,home,nix,local-llms,context,.snapshots,var/log}

    # Mount other subvolumes
    log_info "Mounting other subvolumes..."
    mount -o subvol=@home,compress=zstd:3,noatime "$ROOT_DEVICE" /mnt/home
    mount -o subvol=@nix,noatime "$ROOT_DEVICE" /mnt/nix
    mount -o subvol=@local-llms,compress=zstd:1,noatime "$ROOT_DEVICE" /mnt/local-llms
    mount -o subvol=@context,compress=zstd:3,noatime "$ROOT_DEVICE" /mnt/context
    mount -o subvol=@snapshots,noatime "$ROOT_DEVICE" /mnt/.snapshots
    mount -o subvol=@var-log,compress=zstd:3,noatime "$ROOT_DEVICE" /mnt/var/log

    # Mount EFI partition
    log_info "Mounting EFI partition..."
    mount "$efi_part" /mnt/boot

    log_success "All filesystems mounted"
    echo ""
    df -h /mnt /mnt/boot /mnt/home
}

# Copy qalarc_OS configuration
setup_configuration() {
    log_step "Setting Up Configuration"

    # Create user home directory
    mkdir -p /mnt/home/$USERNAME

    # Copy qalarc_OS from installer or clone from git
    if [ -d "$QALARC_OS_PATH" ]; then
        log_info "Copying qalarc_OS configuration from installer..."
        cp -r "$QALARC_OS_PATH" /mnt/home/$USERNAME/qalarc_OS
        # Fix permissions (files from ISO are read-only)
        chmod -R u+w /mnt/home/$USERNAME/qalarc_OS
    else
        log_info "Cloning qalarc_OS from GitHub..."
        git clone https://github.com/fivelidz/qalarc_OS.git /mnt/home/$USERNAME/qalarc_OS
    fi

    log_success "Configuration copied to /mnt/home/$USERNAME/qalarc_OS"
}

# Generate and configure hardware configuration
configure_hardware() {
    log_step "Generating Hardware Configuration"

    log_info "Running nixos-generate-config..."
    nixos-generate-config --root /mnt

    # Determine which flake target to use
    if [ "$INSTALL_TYPE" = "single-drive" ]; then
        FLAKE_TARGET="gmktec-01-single-drive"
    else
        FLAKE_TARGET="gmktec-01"
    fi

    # Copy generated hardware config to qalarc_OS
    log_info "Copying hardware configuration..."
    cp /mnt/etc/nixos/hardware-configuration.nix \
       /mnt/home/$USERNAME/qalarc_OS/hosts/$FLAKE_TARGET/hardware-configuration.nix

    # Update username in configuration if different from default
    if [ "$USERNAME" != "qalarc" ]; then
        log_info "Updating username in configuration..."
        sed -i "s/qalarc/$USERNAME/g" /mnt/home/$USERNAME/qalarc_OS/hosts/$FLAKE_TARGET/configuration.nix
    fi

    log_success "Hardware configuration generated"
}

# Install NixOS
install_nixos() {
    log_step "Installing NixOS"

    if [ "$INSTALL_TYPE" = "single-drive" ]; then
        FLAKE_TARGET="gmktec-01-single-drive"
    else
        FLAKE_TARGET="gmktec-01"
    fi

    local flake_path="/mnt/home/$USERNAME/qalarc_OS#$FLAKE_TARGET"

    log_info "Installing from flake: $flake_path"
    log_warn "This will take 20-60 minutes depending on internet speed..."
    echo ""

    nixos-install --flake "$flake_path" --no-root-passwd

    log_success "NixOS installation complete!"
}

# Set passwords
set_passwords() {
    log_step "Setting Passwords"

    log_info "Setting root password..."
    nixos-enter --root /mnt -c "passwd root"

    log_info "Setting $USERNAME password..."
    nixos-enter --root /mnt -c "passwd $USERNAME"

    log_success "Passwords configured"
}

# Show completion message
show_completion() {
    log_step "Installation Complete!"

    echo -e "${GREEN}"
    cat << 'EOF'
    ╔════════════════════════════════════════════════════════════════╗
    ║                                                                ║
    ║         ✅ qalarc_OS Installation Complete! ✅                 ║
    ║                                                                ║
    ╠════════════════════════════════════════════════════════════════╣
    ║                                                                ║
    ║  SUCCESS! Your system is ready.                               ║
    ║                                                                ║
    ║  First boot:                                                   ║
    ║   1. Enter LUKS password (if encrypted)                       ║
    ║   2. Login with your username and password                    ║
    ║   3. Verify VRAM: ~/qalarc_OS/scripts/check-uma-allocation.sh ║
    ║   4. Launch AI workspace: qalarc-ai-workspace                 ║
    ║                                                                ║
    ║  Remember:                                                     ║
    ║   • Remove USB drive before reboot                            ║
    ║   • BIOS should have 96GB UMA VRAM configured                 ║
    ║                                                                ║
    ╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    # Unmount filesystems
    log_info "Unmounting filesystems..."
    sync
    umount -R /mnt 2>/dev/null || true

    if [ "$USE_ENCRYPTION" = "yes" ]; then
        cryptsetup close cryptroot 2>/dev/null || true
    fi

    log_success "Filesystems unmounted"

    # Countdown to reboot
    echo ""
    log_warn "System will reboot in 10 seconds..."
    log_warn "Remove USB drive now! (Press Ctrl+C to cancel)"
    echo ""

    for i in 10 9 8 7 6 5 4 3 2 1; do
        echo -ne "\r  Rebooting in ${i}...  "
        sleep 1
    done

    echo ""
    log_info "Rebooting now!"
    reboot
}

# Main installation flow
main() {
    check_root
    show_welcome
    check_network
    select_disk
    configure_options
    partition_disk
    setup_encryption
    format_partitions
    create_subvolumes
    mount_filesystems
    setup_configuration
    configure_hardware
    install_nixos
    set_passwords
    show_completion
}

# Run main
main "$@"
