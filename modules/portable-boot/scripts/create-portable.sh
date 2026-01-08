#!/usr/bin/env bash
# qalarc-create-portable: Create a portable qalarc_OS USB drive
# This script creates a bootable USB that loads the entire OS into RAM

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_VERSION="1.0.0"
COMPRESSION_LEVEL="${QALARC_COMPRESSION_LEVEL:-15}"

# Functions
print_header() {
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║       qalarc_OS Portable Boot Creator v${SCRIPT_VERSION}                 ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${CYAN}[$1/$TOTAL_STEPS]${NC} $2"
}

die() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        die "This script must be run as root. Use: sudo qalarc-create-portable"
    fi
}

list_devices() {
    echo -e "${YELLOW}Available storage devices:${NC}"
    echo ""
    lsblk -d -o NAME,SIZE,MODEL,TRAN,HOTPLUG | head -1
    echo "────────────────────────────────────────────────────────────"
    lsblk -d -o NAME,SIZE,MODEL,TRAN,HOTPLUG | grep -v "^NAME" | grep -v "loop" | while read line; do
        name=$(echo "$line" | awk '{print $1}')
        # Highlight removable devices
        if [[ "$line" == *"usb"* ]] || [[ "$line" == *" 1"* ]]; then
            echo -e "${GREEN}$line${NC}"
        else
            echo "$line"
        fi
    done
    echo ""
}

get_device_info() {
    local dev="$1"
    SIZE_BYTES=$(blockdev --getsize64 "$dev" 2>/dev/null || echo "0")
    SIZE_GB=$((SIZE_BYTES / 1024 / 1024 / 1024))
    MODEL=$(lsblk -d -n -o MODEL "$dev" 2>/dev/null | xargs)
    TRAN=$(lsblk -d -n -o TRAN "$dev" 2>/dev/null | xargs)
}

calculate_sizes() {
    echo "Calculating required space..."
    
    # Base system (Nix closure)
    CURRENT_SYSTEM=$(readlink -f /run/current-system)
    BASE_SIZE_BYTES=$(nix-store -qR "$CURRENT_SYSTEM" | xargs -I{} stat -c%s {} 2>/dev/null | awk '{s+=$1} END {print s}' || echo "5000000000")
    BASE_SIZE_GB=$((BASE_SIZE_BYTES / 1024 / 1024 / 1024))
    
    # Estimate compressed size (roughly 1:3 ratio with zstd)
    BASE_COMPRESSED_GB=$(( (BASE_SIZE_GB + 2) / 3 ))
    [ "$BASE_COMPRESSED_GB" -lt 3 ] && BASE_COMPRESSED_GB=3
    
    # AI models
    AI_SIZE_GB=0
    if [ "$INCLUDE_AI_MODELS" = "yes" ] && [ -d "/var/lib/ollama" ]; then
        AI_SIZE_BYTES=$(du -sb /var/lib/ollama 2>/dev/null | cut -f1 || echo "0")
        AI_SIZE_GB=$((AI_SIZE_BYTES / 1024 / 1024 / 1024))
    fi
    
    # User data
    USER_SIZE_GB=0
    if [ "$INCLUDE_USER_DATA" = "yes" ]; then
        USER_SIZE_BYTES=$(du -sb /home 2>/dev/null | cut -f1 || echo "0")
        USER_SIZE_GB=$((USER_SIZE_BYTES / 1024 / 1024 / 1024))
    fi
    
    # Custom paths
    CUSTOM_SIZE_GB=0
    for path in $INCLUDE_PATHS; do
        if [ -e "$path" ]; then
            path_size=$(du -sb "$path" 2>/dev/null | cut -f1 || echo "0")
            CUSTOM_SIZE_GB=$((CUSTOM_SIZE_GB + path_size / 1024 / 1024 / 1024))
        fi
    done
    
    TOTAL_UNCOMPRESSED_GB=$((BASE_SIZE_GB + AI_SIZE_GB + USER_SIZE_GB + CUSTOM_SIZE_GB))
    TOTAL_COMPRESSED_GB=$((BASE_COMPRESSED_GB + AI_SIZE_GB + USER_SIZE_GB + CUSTOM_SIZE_GB))
    
    # Add overhead for EFI partition and some buffer
    REQUIRED_GB=$((TOTAL_COMPRESSED_GB + 2))
    
    # RAM needed = compressed size + 4GB overhead
    RAM_NEEDED_GB=$((TOTAL_COMPRESSED_GB + 4))
}

show_summary() {
    echo ""
    echo -e "${BLUE}═══ Size Summary ═══${NC}"
    echo "  Base system:     ~${BASE_SIZE_GB}GB uncompressed → ~${BASE_COMPRESSED_GB}GB compressed"
    [ "$INCLUDE_AI_MODELS" = "yes" ] && echo "  AI models:       ~${AI_SIZE_GB}GB"
    [ "$INCLUDE_USER_DATA" = "yes" ] && echo "  User data:       ~${USER_SIZE_GB}GB"
    [ -n "$INCLUDE_PATHS" ] && echo "  Custom paths:    ~${CUSTOM_SIZE_GB}GB"
    echo "  ─────────────────────────────"
    echo "  Total required:  ~${REQUIRED_GB}GB on USB"
    echo "  RAM needed:      ~${RAM_NEEDED_GB}GB minimum"
    echo ""
}

confirm_action() {
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  WARNING: ALL DATA ON $DEVICE WILL BE DESTROYED!             ${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Device: $DEVICE ($MODEL)"
    echo "Size: ${SIZE_GB}GB"
    echo ""
    read -p "Type 'YES' in capitals to proceed: " confirm
    [ "$confirm" = "YES" ] || die "Aborted by user"
}

partition_device() {
    print_step 1 "Partitioning device..."
    
    # Unmount any existing partitions
    umount ${DEVICE}* 2>/dev/null || true
    
    # Create GPT partition table
    parted -s "$DEVICE" mklabel gpt
    
    # Partition 1: EFI System Partition (512MB)
    parted -s "$DEVICE" mkpart ESP fat32 1MiB 513MiB
    parted -s "$DEVICE" set 1 esp on
    parted -s "$DEVICE" set 1 boot on
    
    # Partition 2: Boot partition with squashfs (calculated size + buffer)
    BOOT_END=$((513 + (TOTAL_COMPRESSED_GB * 1024) + 1024))
    parted -s "$DEVICE" mkpart primary ext4 513MiB ${BOOT_END}MiB
    
    # Partition 3: Persistence (rest of disk)
    if [ "$ENABLE_PERSISTENCE" = "yes" ]; then
        parted -s "$DEVICE" mkpart primary ext4 ${BOOT_END}MiB 100%
    fi
    
    # Wait for kernel
    sleep 2
    partprobe "$DEVICE"
    sleep 2
    
    # Determine partition names
    if [[ "$DEVICE" == *"nvme"* ]] || [[ "$DEVICE" == *"mmcblk"* ]]; then
        EFI_PART="${DEVICE}p1"
        BOOT_PART="${DEVICE}p2"
        PERSIST_PART="${DEVICE}p3"
    else
        EFI_PART="${DEVICE}1"
        BOOT_PART="${DEVICE}2"
        PERSIST_PART="${DEVICE}3"
    fi
    
    success "Partitioned: EFI(512MB), Boot(${TOTAL_COMPRESSED_GB}GB+), Persistence(remaining)"
}

format_partitions() {
    print_step 2 "Formatting partitions..."
    
    mkfs.vfat -F32 -n "QALARC_EFI" "$EFI_PART"
    mkfs.ext4 -F -L "QALARC_BOOT" "$BOOT_PART"
    
    if [ "$ENABLE_PERSISTENCE" = "yes" ]; then
        mkfs.ext4 -F -L "QALARC_DATA" "$PERSIST_PART"
    fi
    
    success "Formatted all partitions"
}

mount_partitions() {
    print_step 3 "Mounting partitions..."
    
    WORK_DIR=$(mktemp -d)
    mkdir -p "$WORK_DIR"/{efi,boot,data,squashroot}
    
    mount "$EFI_PART" "$WORK_DIR/efi"
    mount "$BOOT_PART" "$WORK_DIR/boot"
    
    if [ "$ENABLE_PERSISTENCE" = "yes" ]; then
        mount "$PERSIST_PART" "$WORK_DIR/data"
    fi
    
    success "Mounted working directories"
}

build_squashfs() {
    print_step 4 "Building system image (this takes 10-30 minutes)..."
    
    SQUASH_ROOT="$WORK_DIR/squashroot"
    
    # Create directory structure
    mkdir -p "$SQUASH_ROOT"/{nix/store,nix/var/nix/profiles,etc,bin,sbin,lib,lib64}
    mkdir -p "$SQUASH_ROOT"/{proc,sys,dev,run,tmp,var,home,root,mnt,boot}
    
    # Get current system
    CURRENT_SYSTEM=$(readlink -f /run/current-system)
    echo "  System: $CURRENT_SYSTEM"
    
    # Get all store paths
    echo "  Analyzing Nix closure..."
    CLOSURE=$(nix-store -qR "$CURRENT_SYSTEM")
    TOTAL_PATHS=$(echo "$CLOSURE" | wc -l)
    
    echo "  Copying $TOTAL_PATHS store paths..."
    CURRENT=0
    for path in $CLOSURE; do
        CURRENT=$((CURRENT + 1))
        if [ $((CURRENT % 100)) -eq 0 ]; then
            PCT=$((CURRENT * 100 / TOTAL_PATHS))
            printf "\r  Progress: %3d%% (%d/%d)" "$PCT" "$CURRENT" "$TOTAL_PATHS"
        fi
        
        if [ -e "$path" ]; then
            cp -a "$path" "$SQUASH_ROOT/nix/store/" 2>/dev/null || true
        fi
    done
    echo ""
    
    # Copy system profile
    cp -a /nix/var/nix/profiles/system* "$SQUASH_ROOT/nix/var/nix/profiles/" 2>/dev/null || true
    
    # Copy /etc
    echo "  Copying system configuration..."
    cp -a /etc/. "$SQUASH_ROOT/etc/" 2>/dev/null || true
    
    # Include AI models if requested
    if [ "$INCLUDE_AI_MODELS" = "yes" ] && [ -d "/var/lib/ollama" ]; then
        echo "  Including AI models..."
        mkdir -p "$SQUASH_ROOT/var/lib"
        cp -a /var/lib/ollama "$SQUASH_ROOT/var/lib/"
    fi
    
    # Include user data if requested
    if [ "$INCLUDE_USER_DATA" = "yes" ]; then
        echo "  Including user data..."
        cp -a /home/. "$SQUASH_ROOT/home/"
    fi
    
    # Include custom paths
    for path in $INCLUDE_PATHS; do
        if [ -e "$path" ]; then
            echo "  Including $path..."
            parent=$(dirname "$path")
            mkdir -p "$SQUASH_ROOT$parent"
            cp -a "$path" "$SQUASH_ROOT$parent/"
        fi
    done
    
    # Create squashfs
    echo "  Compressing with zstd level $COMPRESSION_LEVEL..."
    mksquashfs "$SQUASH_ROOT" "$WORK_DIR/boot/qalarc.squashfs" \
        -comp zstd \
        -Xcompression-level "$COMPRESSION_LEVEL" \
        -b 1M \
        -no-xattrs \
        -progress
    
    SQUASH_SIZE=$(du -h "$WORK_DIR/boot/qalarc.squashfs" | cut -f1)
    success "Created qalarc.squashfs ($SQUASH_SIZE)"
}

install_bootloader() {
    print_step 5 "Installing bootloaders..."
    
    CURRENT_SYSTEM=$(readlink -f /run/current-system)
    
    # Copy kernel and initrd
    KERNEL=$(readlink -f "$CURRENT_SYSTEM/kernel")
    INITRD=$(readlink -f "$CURRENT_SYSTEM/initrd")
    
    cp "$KERNEL" "$WORK_DIR/efi/vmlinuz"
    cp "$INITRD" "$WORK_DIR/efi/initrd.img"
    cp "$KERNEL" "$WORK_DIR/boot/vmlinuz"
    cp "$INITRD" "$WORK_DIR/boot/initrd.img"
    
    # Install systemd-boot for UEFI
    mkdir -p "$WORK_DIR/efi/EFI/BOOT"
    mkdir -p "$WORK_DIR/efi/loader/entries"
    
    # Find systemd-boot binary
    BOOTX64=$(find "$CURRENT_SYSTEM" -name "systemd-bootx64.efi" 2>/dev/null | head -1)
    if [ -n "$BOOTX64" ]; then
        cp "$BOOTX64" "$WORK_DIR/efi/EFI/BOOT/BOOTX64.EFI"
    fi
    
    # Loader config
    cat > "$WORK_DIR/efi/loader/loader.conf" << 'EOF'
default qalarc-portable.conf
timeout 5
console-mode max
editor no
EOF
    
    # Boot entry
    cat > "$WORK_DIR/efi/loader/entries/qalarc-portable.conf" << EOF
title   qalarc_OS Portable (Boot to RAM)
linux   /vmlinuz
initrd  /initrd.img
options init=/nix/var/nix/profiles/system/init copytoram root=LABEL=QALARC_BOOT quiet splash
EOF
    
    cat > "$WORK_DIR/efi/loader/entries/qalarc-safe.conf" << EOF
title   qalarc_OS Portable (Safe Mode)
linux   /vmlinuz
initrd  /initrd.img
options init=/nix/var/nix/profiles/system/init copytoram root=LABEL=QALARC_BOOT nomodeset
EOF
    
    # Install GRUB for legacy BIOS
    echo "  Installing GRUB for legacy BIOS..."
    grub-install --target=i386-pc --boot-directory="$WORK_DIR/boot" "$DEVICE" 2>/dev/null || warn "GRUB legacy install failed (UEFI-only system?)"
    
    mkdir -p "$WORK_DIR/boot/grub"
    cat > "$WORK_DIR/boot/grub/grub.cfg" << 'EOF'
set timeout=5
set default=0

menuentry "qalarc_OS Portable (Boot to RAM)" {
    linux /vmlinuz init=/nix/var/nix/profiles/system/init copytoram root=LABEL=QALARC_BOOT quiet splash
    initrd /initrd.img
}

menuentry "qalarc_OS Portable (Safe Mode)" {
    linux /vmlinuz init=/nix/var/nix/profiles/system/init copytoram root=LABEL=QALARC_BOOT nomodeset
    initrd /initrd.img
}
EOF
    
    success "Bootloaders installed (UEFI + BIOS)"
}

setup_persistence() {
    if [ "$ENABLE_PERSISTENCE" = "yes" ]; then
        print_step 6 "Setting up persistence partition..."
        
        mkdir -p "$WORK_DIR/data"/{home,var,etc}
        
        cat > "$WORK_DIR/data/README.md" << 'EOF'
# qalarc_OS Persistence Partition

This partition stores data that survives reboots.

## Usage

The system runs entirely from RAM. Changes are temporary unless synced.

To save changes:
```bash
sudo qalarc-sync-portable
```

## Structure

- `home/` - User home directories
- `var/` - Variable data (logs, caches)
- `etc/` - System configuration overrides

## Notes

- USB must be connected to sync
- Run sync before shutdown to save work
- Deleted files won't auto-restore; manually manage this partition
EOF
        
        success "Persistence partition ready"
    fi
}

verify_installation() {
    print_step 7 "Verifying installation..."
    
    ERRORS=0
    
    # Check essential files
    [ -f "$WORK_DIR/boot/qalarc.squashfs" ] && success "squashfs image" || { warn "squashfs missing"; ERRORS=$((ERRORS+1)); }
    [ -f "$WORK_DIR/efi/vmlinuz" ] && success "kernel" || { warn "kernel missing"; ERRORS=$((ERRORS+1)); }
    [ -f "$WORK_DIR/efi/initrd.img" ] && success "initrd" || { warn "initrd missing"; ERRORS=$((ERRORS+1)); }
    [ -f "$WORK_DIR/efi/EFI/BOOT/BOOTX64.EFI" ] && success "UEFI bootloader" || { warn "UEFI bootloader missing"; ERRORS=$((ERRORS+1)); }
    [ -f "$WORK_DIR/boot/grub/grub.cfg" ] && success "GRUB config" || { warn "GRUB config missing"; ERRORS=$((ERRORS+1)); }
    
    # Verify squashfs integrity
    if unsquashfs -l "$WORK_DIR/boot/qalarc.squashfs" > /dev/null 2>&1; then
        success "squashfs integrity"
    else
        warn "squashfs may be corrupted"
        ERRORS=$((ERRORS+1))
    fi
    
    return $ERRORS
}

cleanup() {
    print_step 8 "Cleaning up..."
    
    # Unmount in reverse order
    umount "$WORK_DIR/data" 2>/dev/null || true
    umount "$WORK_DIR/boot" 2>/dev/null || true
    umount "$WORK_DIR/efi" 2>/dev/null || true
    
    # Remove temp directory
    rm -rf "$WORK_DIR"
    
    success "Cleanup complete"
}

print_success() {
    SQUASH_SIZE=$(lsblk -b -n -o SIZE "$BOOT_PART" | awk '{print int($1/1024/1024/1024)}')
    
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              SUCCESS! Portable USB is ready!                  ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "  Device:      $DEVICE ($MODEL)"
    echo "  Image size:  ~${TOTAL_COMPRESSED_GB}GB compressed"
    echo "  RAM needed:  ${RAM_NEEDED_GB}GB minimum"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Safely eject: sudo eject $DEVICE"
    echo "  2. Boot target computer from USB"
    echo "  3. Wait 2-5 minutes for system to load"
    echo "  4. USB can be removed once desktop appears"
    echo ""
    echo "  Guide: /etc/qalarc-portable/PORTABLE_BOOT_GUIDE.md"
    echo ""
}

# Parse arguments
INCLUDE_AI_MODELS="no"
INCLUDE_USER_DATA="no"
ENABLE_PERSISTENCE="yes"
INCLUDE_PATHS=""
DEVICE=""
INTERACTIVE="yes"
TOTAL_STEPS=8

while [[ $# -gt 0 ]]; do
    case $1 in
        --device|-d)
            DEVICE="/dev/$2"
            shift 2
            ;;
        --ai-models)
            INCLUDE_AI_MODELS="yes"
            shift
            ;;
        --user-data)
            INCLUDE_USER_DATA="yes"
            shift
            ;;
        --no-persistence)
            ENABLE_PERSISTENCE="no"
            TOTAL_STEPS=7
            shift
            ;;
        --include)
            INCLUDE_PATHS="$INCLUDE_PATHS $2"
            shift 2
            ;;
        --compression)
            COMPRESSION_LEVEL="$2"
            shift 2
            ;;
        --non-interactive|-y)
            INTERACTIVE="no"
            shift
            ;;
        --minimal)
            INCLUDE_AI_MODELS="no"
            INCLUDE_USER_DATA="no"
            shift
            ;;
        --help|-h)
            echo "Usage: qalarc-create-portable [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -d, --device DEVICE    Target device (e.g., sdb)"
            echo "  --ai-models            Include AI models from /var/lib/ollama"
            echo "  --user-data            Include /home directory"
            echo "  --no-persistence       Don't create persistence partition"
            echo "  --include PATH         Include additional path (can repeat)"
            echo "  --compression LEVEL    zstd level 1-19 (default: 15)"
            echo "  --minimal              Create minimal image (no extras)"
            echo "  -y, --non-interactive  Skip confirmations (dangerous!)"
            echo "  -h, --help             Show this help"
            exit 0
            ;;
        *)
            die "Unknown option: $1"
            ;;
    esac
done

# Main flow
check_root
print_header

# Interactive device selection if not specified
if [ -z "$DEVICE" ]; then
    list_devices
    read -p "Enter target device (e.g., sdb): " dev_input
    DEVICE="/dev/$dev_input"
fi

# Validate device
[ -b "$DEVICE" ] || die "Device $DEVICE does not exist"
get_device_info "$DEVICE"

# Interactive options if not specified via CLI
if [ "$INTERACTIVE" = "yes" ]; then
    echo ""
    echo -e "${BLUE}═══ Configuration ═══${NC}"
    
    if [ "$INCLUDE_AI_MODELS" = "no" ]; then
        read -p "Include AI models from /var/lib/ollama? (y/N): " ai_input
        [ "$ai_input" = "y" ] || [ "$ai_input" = "Y" ] && INCLUDE_AI_MODELS="yes"
    fi
    
    if [ "$INCLUDE_AI_MODELS" = "yes" ]; then
        warn "AI models can add 10-50GB to the image!"
    fi
    
    if [ "$INCLUDE_USER_DATA" = "no" ]; then
        read -p "Include user data from /home? (y/N): " user_input
        [ "$user_input" = "y" ] || [ "$user_input" = "Y" ] && INCLUDE_USER_DATA="yes"
    fi
fi

# Calculate sizes
calculate_sizes

# Check device capacity
if [ "$SIZE_GB" -lt "$REQUIRED_GB" ]; then
    die "Device too small. Need ${REQUIRED_GB}GB, have ${SIZE_GB}GB"
fi

show_summary

# Confirm
if [ "$INTERACTIVE" = "yes" ]; then
    confirm_action
fi

# Execute
trap cleanup EXIT

partition_device
format_partitions
mount_partitions
build_squashfs
install_bootloader
setup_persistence

if verify_installation; then
    print_success
else
    warn "Some verification checks failed. USB may still work."
fi
