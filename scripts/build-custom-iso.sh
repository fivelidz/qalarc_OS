#!/usr/bin/env bash
#
# build-custom-iso.sh
# Build custom qalarc_OS installer ISO with configuration pre-loaded
#
# Requirements: NixOS or system with Nix package manager installed
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

# Check if nix is installed
if ! command -v nix &> /dev/null; then
    log_error "Nix is not installed!"
    log_info "This script requires the Nix package manager."
    log_info ""
    log_info "Install Nix on CachyOS/Arch:"
    log_info "  sh <(curl -L https://nixos.org/nix/install) --daemon"
    log_info ""
    log_info "Or run this script on an existing NixOS system."
    exit 1
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         qalarc_OS Custom Installer ISO Builder            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

log_info "Building custom NixOS installer ISO..."
log_info "This will take 10-30 minutes depending on your system."
log_info ""
log_warn "This will download ~2-3GB of packages."
echo ""

# Build the ISO
log_info "Starting build..."
nix build .#nixosConfigurations.installer.config.system.build.isoImage \
  --print-build-logs

if [ $? -eq 0 ]; then
    log_success "ISO build complete!"
    echo ""

    # Find the ISO
    ISO_PATH=$(readlink -f result/iso/*.iso)
    ISO_SIZE=$(du -h "$ISO_PATH" | cut -f1)

    log_success "Custom ISO created:"
    log_info "  Path: $ISO_PATH"
    log_info "  Size: $ISO_SIZE"
    echo ""

    log_info "To write to USB:"
    log_info "  sudo dd if=$ISO_PATH of=/dev/sdX bs=4M status=progress oflag=sync"
    log_info "  (Replace /dev/sdX with your USB device)"
    echo ""

    log_info "Or use the helper script:"
    log_info "  sudo ./scripts/write-custom-iso-to-usb.sh /dev/sdX"
    echo ""

else
    log_error "ISO build failed!"
    log_info "Check the build log for errors."
    exit 1
fi
