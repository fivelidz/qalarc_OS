#!/usr/bin/env bash
#
# create-usb-installer.sh
# Create a bootable NixOS USB installer with qalarc_OS configuration
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
NIXOS_VERSION="25.05"
ISO_URL="https://channels.nixos.org/nixos-${NIXOS_VERSION}/latest-nixos-minimal-x86_64-linux.iso"
ISO_NAME="nixos-${NIXOS_VERSION}-minimal-x86_64-linux.iso"
DOWNLOAD_DIR="/tmp/qalarc-installer"

show_help() {
    cat << EOF
Usage: $0 [USB_DEVICE]

Create a bootable NixOS USB installer for qalarc_OS deployment.

Arguments:
    USB_DEVICE    Target USB device (e.g., /dev/sdb)
                  Leave empty to list available devices

Examples:
    $0              # List available USB devices
    $0 /dev/sdb     # Write to /dev/sdb (WARNING: Will erase /dev/sdb!)

Steps:
    1. Downloads NixOS ${NIXOS_VERSION} minimal ISO
    2. Writes ISO to USB device
    3. Copies qalarc_OS configuration to USB
    4. Provides installation instructions

Requirements:
    - Root/sudo access
    - 8GB+ USB drive
    - Internet connection for ISO download
EOF
}

list_devices() {
    log_info "Available block devices:"
    echo ""
    lsblk -d -o NAME,SIZE,TYPE,TRAN,MODEL | grep -E "disk|NAME"
    echo ""
    log_warn "USB devices typically show TRAN=usb"
    log_warn "Common USB devices: /dev/sdb, /dev/sdc, /dev/sdd"
}

confirm_device() {
    local device=$1

    if [ ! -b "$device" ]; then
        log_error "Device $device does not exist or is not a block device"
        exit 1
    fi

    log_warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_warn "⚠️  WARNING: This will COMPLETELY ERASE $device!"
    log_warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    lsblk "$device" -o NAME,SIZE,TYPE,MOUNTPOINT,LABEL,MODEL
    echo ""

    read -p "Are you ABSOLUTELY SURE you want to erase $device? (type 'YES' to confirm): " confirm

    if [ "$confirm" != "YES" ]; then
        log_error "Aborted by user"
        exit 1
    fi
}

download_iso() {
    mkdir -p "$DOWNLOAD_DIR"

    if [ -f "$DOWNLOAD_DIR/$ISO_NAME" ]; then
        log_info "ISO already downloaded: $DOWNLOAD_DIR/$ISO_NAME"
        read -p "Re-download? (y/N): " redownload
        if [ "$redownload" = "y" ] || [ "$redownload" = "Y" ]; then
            rm "$DOWNLOAD_DIR/$ISO_NAME"
        else
            return 0
        fi
    fi

    log_info "Downloading NixOS ${NIXOS_VERSION} minimal ISO..."
    log_info "URL: $ISO_URL"

    if command -v wget &> /dev/null; then
        wget -O "$DOWNLOAD_DIR/$ISO_NAME" "$ISO_URL" --progress=bar:force:noscroll
    elif command -v curl &> /dev/null; then
        curl -L -o "$DOWNLOAD_DIR/$ISO_NAME" "$ISO_URL" --progress-bar
    else
        log_error "Neither wget nor curl found. Please install one of them."
        exit 1
    fi

    log_success "ISO downloaded to $DOWNLOAD_DIR/$ISO_NAME"
}

write_iso() {
    local device=$1

    # Unmount any mounted partitions
    log_info "Unmounting any mounted partitions on $device..."
    sudo umount ${device}* 2>/dev/null || true

    log_info "Writing ISO to $device..."
    log_warn "This will take 5-10 minutes..."

    sudo dd if="$DOWNLOAD_DIR/$ISO_NAME" of="$device" bs=4M status=progress oflag=sync

    log_success "ISO written to $device"

    # Sync to ensure all data is written
    log_info "Syncing..."
    sudo sync

    log_success "USB installer created successfully!"
}

show_next_steps() {
    local device=$1

    echo ""
    log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_success "✅ Bootable NixOS USB created on $device"
    log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    cat << EOF
📋 NEXT STEPS:

1️⃣  CONFIGURE BIOS (GMKTEC EVO-X2 AI):
   - Reboot and enter BIOS (press F2 or Del at boot)
   - Advanced → Graphics Configuration
   - Set "Dedicated Graphics Memory" to 96GB
   - Save and exit

2️⃣  BOOT FROM USB:
   - Insert USB into target system
   - Boot from USB (F12 boot menu or BIOS boot order)
   - Select USB device to boot NixOS installer

3️⃣  INSTALL NIXOS:
   Option A - Automatic (recommended):
   # Not yet implemented - follow Option B

   Option B - Manual (current method):
   a) Connect to WiFi/Ethernet
   b) Clone qalarc_OS repository:
      git clone https://github.com/fivelidz/qalarc_OS.git
   c) Follow installation guide:
      cat qalarc_OS/docs/INSTALLATION.md

   Key steps:
   - Partition disk (LUKS encryption recommended)
   - Create BTRFS subvolumes
   - Generate hardware-configuration.nix
   - Copy qalarc_OS config
   - nixos-install

4️⃣  POST-INSTALL:
   - Verify 96GB VRAM: ./scripts/check-uma-allocation.sh
   - Launch AI workspace: qalarc-ai-workspace
   - Set up Tailscale: sudo tailscale up

📚 Documentation:
   - Installation guide: docs/INSTALLATION.md (TODO)
   - UMA setup: docs/UMA-CONFIGURATION.md (TODO)
   - System architecture: docs/ARCHITECTURE.md (TODO)

💡 TIP: Keep this USB as a recovery disk! You can boot into any
    snapshot from GRUB menu if something breaks.
EOF
}

main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         qalarc_OS Bootable USB Creator                    ║"
    echo "║         NixOS ${NIXOS_VERSION} Minimal Installer                    ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    # Check for help flag
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        exit 0
    fi

    # List devices if no argument provided
    if [ -z "$1" ]; then
        list_devices
        echo ""
        log_info "Run: $0 /dev/sdX (where X is your USB device)"
        log_info "Or run: $0 --help for more information"
        exit 0
    fi

    USB_DEVICE="$1"

    # Confirm device
    confirm_device "$USB_DEVICE"

    # Download ISO
    download_iso

    # Write to USB
    write_iso "$USB_DEVICE"

    # Show next steps
    show_next_steps "$USB_DEVICE"
}

# Require root for dd command
if [ "$EUID" -ne 0 ] && [ -n "$1" ] && [ "$1" != "-h" ] && [ "$1" != "--help" ]; then
    log_error "This script requires root privileges to write to USB"
    log_info "Run with: sudo $0 $@"
    exit 1
fi

main "$@"
