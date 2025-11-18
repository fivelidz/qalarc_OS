#!/usr/bin/env bash
# qalarc_OS ISO Builder
# Creates bootable installation media with qalarc_OS installer
# Uses nixos-generators for ISO creation

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/output"
ISO_NAME="qalarc-os-$(date +%Y%m%d).iso"
FLAKE_FILE="$SCRIPT_DIR/flake.nix"

# ============================================================================
# Banner
# ============================================================================

print_banner() {
    clear
    echo -e "${BLUE}"
    cat << "EOF"
   ┏━┓┏━┓╻  ┏━┓┏━┓┏━╸   ┏━┓┏━┓
   ┃┓┃┣━┫┃  ┣━┫┣┳┛┃     ┃ ┃┗━┓
   ┗┻┛╹ ╹┗━╸╹ ╹╹┗╸┗━╸   ┗━┛┗━┛

   ISO Builder v1.0.0
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

# ============================================================================
# Prerequisites Check
# ============================================================================

check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check if running NixOS
    if [ ! -f /etc/NIXOS ]; then
        log_error "This script must be run on NixOS"
        exit 1
    fi

    # Check if nixos-generators is available
    if ! command -v nixos-generate &> /dev/null; then
        log_warn "nixos-generators not found. Installing..."
        nix-shell -p nixos-generators --run "echo 'nixos-generators loaded'"
    fi

    # Check for git (needed for flakes)
    if ! command -v git &> /dev/null; then
        log_error "git is required but not installed"
        exit 1
    fi

    log_success "Prerequisites check passed"
}

# ============================================================================
# Create Flake Configuration
# ============================================================================

create_flake() {
    log_info "Creating flake configuration..."

    cat > "$FLAKE_FILE" << 'EOF'
{
  description = "qalarc_OS Installation ISO";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators, ... }: {
    # ISO image for installation
    packages.x86_64-linux = {
      iso = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        modules = [
          # Base ISO configuration
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

          # Custom qalarc_OS configuration
          ({ pkgs, ... }: {
            # ISO Settings
            isoImage.squashfsCompression = "zstd -Xcompression-level 6";
            isoImage.makeEfiBootable = true;
            isoImage.makeUsbBootable = true;

            # Essential packages for installation
            environment.systemPackages = with pkgs; [
              # Installer scripts
              (pkgs.writeScriptBin "qalarc-install" ''
                #!/usr/bin/env bash
                ${builtins.readFile ./installer.sh}
              '')

              # Hardware detection
              (pkgs.writeScriptBin "qalarc-detect-hardware" ''
                #!/usr/bin/env bash
                ${builtins.readFile ./detect-hardware.sh}
              '')

              # UI tools
              dialog
              whiptail

              # Disk tools
              parted
              gptfdisk
              dosfstools
              btrfs-progs
              e2fsprogs

              # System tools
              git
              curl
              wget
              lshw
              pciutils
              dmidecode
              bc

              # Network
              networkmanager

              # Utilities
              vim
              tmux
              htop
              tree
            ];

            # Auto-login to installer
            services.getty.autologinUser = "nixos";

            # Welcome message
            programs.bash.interactiveShellInit = ''
              if [ "$(tty)" = "/dev/tty1" ]; then
                clear
                echo -e "\033[0;36m"
                cat << "BANNER"
   ┏━┓┏━┓╻  ┏━┓┏━┓┏━╸   ┏━┓┏━┓
   ┃┓┃┣━┫┃  ┣━┫┣┳┛┃     ┃ ┃┗━┓
   ┗┻┛╹ ╹┗━╸╹ ╹╹┗╸┗━╸   ┗━┛┗━┛

   Welcome to qalarc_OS Installer
BANNER
                echo -e "\033[0m"
                echo ""
                echo "To start installation, run: qalarc-install"
                echo "To detect hardware, run: qalarc-detect-hardware"
                echo ""
                echo "For manual NixOS installation, see: nixos-install --help"
                echo ""
              fi
            '';

            # Enable SSH for remote installation
            services.openssh = {
              enable = true;
              settings.PermitRootLogin = "yes";
            };

            # Set default password for live environment
            users.users.nixos.initialPassword = "qalarc";

            # Networking
            networking.networkmanager.enable = true;
            networking.wireless.enable = false;

            # Timezone
            time.timeZone = "America/New_York";

            # Locale
            i18n.defaultLocale = "en_US.UTF-8";
          })
        ];
        format = "iso";
      };

      # Convenience: default package is the ISO
      default = self.packages.x86_64-linux.iso;
    };
  };
}
EOF

    log_success "Flake configuration created"
}

# ============================================================================
# Initialize Git (required for flakes)
# ============================================================================

init_git() {
    if [ ! -d "$SCRIPT_DIR/.git" ]; then
        log_info "Initializing git repository (required for flakes)..."
        cd "$SCRIPT_DIR"
        git init
        git add .
        git commit -m "qalarc_OS installer initial commit" || true
        log_success "Git repository initialized"
    fi
}

# ============================================================================
# Build ISO
# ============================================================================

build_iso() {
    log_info "Building ISO image..."
    log_warn "This may take 10-30 minutes depending on your system"

    mkdir -p "$OUTPUT_DIR"

    cd "$SCRIPT_DIR"

    # Build using nix flakes
    log_info "Running: nix build .#iso"

    if nix build .#iso --print-build-logs; then
        log_success "ISO build completed successfully!"

        # Copy result to output directory
        if [ -L "./result" ]; then
            ISO_PATH=$(readlink -f ./result)
            cp "$ISO_PATH/iso/"*.iso "$OUTPUT_DIR/$ISO_NAME"
            log_success "ISO saved to: $OUTPUT_DIR/$ISO_NAME"

            # Get size
            ISO_SIZE=$(du -h "$OUTPUT_DIR/$ISO_NAME" | cut -f1)
            log_info "ISO Size: $ISO_SIZE"
        else
            log_error "Build result not found"
            exit 1
        fi
    else
        log_error "ISO build failed"
        exit 1
    fi
}

# ============================================================================
# Create Checksum
# ============================================================================

create_checksum() {
    log_info "Creating SHA256 checksum..."

    cd "$OUTPUT_DIR"
    sha256sum "$ISO_NAME" > "${ISO_NAME}.sha256"

    log_success "Checksum created: ${ISO_NAME}.sha256"
    cat "${ISO_NAME}.sha256"
}

# ============================================================================
# Write to USB Instructions
# ============================================================================

show_instructions() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}ISO Build Complete!${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
    echo "ISO Location: $OUTPUT_DIR/$ISO_NAME"
    echo "Checksum: $OUTPUT_DIR/${ISO_NAME}.sha256"
    echo ""
    echo -e "${YELLOW}To write to USB drive:${NC}"
    echo ""
    echo "1. Insert USB drive"
    echo "2. Find device name:"
    echo "   lsblk"
    echo ""
    echo "3. Write ISO (replace /dev/sdX with your USB device):"
    echo "   sudo dd if=$OUTPUT_DIR/$ISO_NAME of=/dev/sdX bs=4M status=progress oflag=sync"
    echo ""
    echo "4. Or use a graphical tool:"
    echo "   - Etcher (https://www.balena.io/etcher/)"
    echo "   - Ventoy (https://www.ventoy.net/)"
    echo ""
    echo -e "${YELLOW}To test in VM:${NC}"
    echo "   virt-manager (use ISO as CD-ROM)"
    echo "   qemu-system-x86_64 -cdrom $OUTPUT_DIR/$ISO_NAME -boot d -m 4G"
    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_banner

    log_info "Starting qalarc_OS ISO build process..."
    echo ""

    check_prerequisites
    create_flake
    init_git
    build_iso
    create_checksum
    show_instructions
}

main "$@"
