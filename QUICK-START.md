# qalarc_OS Quick Start Guide

## Installation on GMKTEC EVO-X2 AI

### Prerequisites
- ✅ NixOS USB installer (already created)
- ✅ qalarc_OS repository cloned from GitHub
- ⚠️ **CRITICAL**: BIOS configured for 96GB UMA VRAM

---

## Step 1: Boot USB and Connect to Internet

1. Boot from USB installer
2. Login: `nixos` / Password: `nixos`
3. Connect to internet:
   ```bash
   # WiFi:
   nmtui

   # Or ethernet (should auto-connect):
   ping google.com
   ```

---

## Step 2: VERIFY BIOS SETTINGS FIRST! ⚠️

**DO THIS BEFORE PARTITIONING!**

Reboot into BIOS (F2 or Del during boot):
- Navigate to: **Advanced → Graphics Configuration**
- Set: **Dedicated Graphics Memory = 96GB**
- Save and exit

Boot back to USB installer.

---

## Step 3: Partition Disks

```bash
# List all NVMe drives
lsblk
```

**Expected drives:**
- `/dev/nvme0n1` - 2TB (System drive)
- `/dev/nvme1n1` - 4TB (AI models)
- `/dev/nvme2n1` - 4TB (Context library)

### System Drive (nvme0n1)

```bash
gdisk /dev/nvme0n1
```

**Recommended layout:**
- `/dev/nvme0n1p1`: 512MB (EFI System)
- `/dev/nvme0n1p2`: Remaining ~2TB (Linux filesystem - will be LUKS + BTRFS)

**gdisk commands:**
```
o     # Create new GPT partition table
n     # New partition 1 (EFI)
      # First sector: default (press Enter)
      # Last sector: +512M
      # Type: ef00 (EFI)

n     # New partition 2 (root)
      # First sector: default
      # Last sector: default (use rest of disk)
      # Type: 8300 (Linux filesystem)

w     # Write changes
y     # Confirm
```

### AI Models Drive (nvme1n1)

```bash
# Single BTRFS partition (optionally encrypted)
mkfs.btrfs -L "AI-MODELS" /dev/nvme1n1
```

### Context Library Drive (nvme2n1)

```bash
# Single BTRFS partition
mkfs.btrfs -L "CONTEXT" /dev/nvme2n1
```

---

## Step 4: Encrypt System Partition (Recommended)

```bash
# Encrypt
cryptsetup luksFormat /dev/nvme0n1p2
# Enter passphrase (WRITE IT DOWN!)

# Open encrypted partition
cryptsetup luksOpen /dev/nvme0n1p2 cryptroot
```

---

## Step 5: Format and Create BTRFS Subvolumes

```bash
# Format EFI partition
mkfs.fat -F32 /dev/nvme0n1p1

# Format BTRFS on encrypted system partition
mkfs.btrfs /dev/mapper/cryptroot
# (If not using encryption: mkfs.btrfs /dev/nvme0n1p2)

# Mount to create subvolumes (system drive only)
mount /dev/mapper/cryptroot /mnt
cd /mnt

# Create system subvolumes (NOT local-llms/context - those are separate drives)
btrfs subvolume create @
btrfs subvolume create @home
btrfs subvolume create @nix
btrfs subvolume create @snapshots
btrfs subvolume create @var-log

# Unmount
cd /
umount /mnt
```

**Note**: `/local-llms` and `/context` are already formatted as separate drives in Step 3.

---

## Step 6: Mount Everything

```bash
# Mount root subvolume (system drive)
mount -o subvol=@,compress=zstd:3,noatime /dev/mapper/cryptroot /mnt

# Create mount points
mkdir -p /mnt/{boot,home,nix,local-llms,context,.snapshots,var/log}

# Mount system subvolumes
mount -o subvol=@home,compress=zstd:3,noatime /dev/mapper/cryptroot /mnt/home
mount -o subvol=@nix,noatime /dev/mapper/cryptroot /mnt/nix
mount -o subvol=@snapshots,noatime /dev/mapper/cryptroot /mnt/.snapshots
mount -o subvol=@var-log,compress=zstd:3,noatime /dev/mapper/cryptroot /mnt/var/log

# Mount EFI partition
mount /dev/nvme0n1p1 /mnt/boot

# Mount dedicated drives
mount -o compress=zstd:1,noatime /dev/nvme1n1 /mnt/local-llms    # 4TB AI models
mount -o compress=zstd:3,noatime /dev/nvme2n1 /mnt/context       # 4TB context library

# Verify mounts
df -h /mnt
```

---

## Step 7: Clone qalarc_OS Repository

```bash
# Install git (should be available on installer)
nix-shell -p git

# Clone repository
cd /mnt
git clone https://github.com/fivelidz/qalarc_OS.git /mnt/home/qalarc_OS

# Or if already downloaded to USB:
cp -r /path/to/qalarc_OS /mnt/home/qalarc_OS
```

---

## Step 8: Generate Hardware Configuration

```bash
# Generate hardware config (will auto-detect all 3 NVMe drives)
nixos-generate-config --root /mnt

# Copy to qalarc_OS repository
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/qalarc_OS/hosts/gmktec-01/

# Get UUIDs for the 4TB drives
lsblk -o NAME,UUID,SIZE,FSTYPE

# IMPORTANT: Edit hardware-configuration.nix
nano /mnt/home/qalarc_OS/hosts/gmktec-01/hardware-configuration.nix
```

**Replace UUIDs for dedicated drives:**
- Find lines with `REPLACE-WITH-NVME1-UUID` and `REPLACE-WITH-NVME2-UUID`
- Replace with actual UUIDs from `lsblk` output
- nvme1n1 UUID → `/local-llms` mount
- nvme2n1 UUID → `/context` mount

**Verify the following are in hardware-configuration.nix:**
- All BTRFS mount points with correct subvolumes
- Correct UUIDs for 3 NVMe drives
- LUKS configuration (if encrypted)
- Boot loader settings

---

## Step 9: Review Configuration

```bash
# Check main config
cat /mnt/home/qalarc_OS/hosts/gmktec-01/configuration.nix

# Check flake
cat /mnt/home/qalarc_OS/flake.nix
```

**Key settings to verify:**
- Hostname: `gmktec-01`
- Bootloader: GRUB with EFI
- CachyOS kernel enabled
- ROCm environment variables (HSA_OVERRIDE_GFX_VERSION = "11.5.1")

---

## Step 10: Install NixOS

```bash
# Install from flake
nixos-install --flake /mnt/home/qalarc_OS#gmktec-01

# This will:
# - Download all packages (~10-20GB)
# - Build system configuration
# - Set up GRUB bootloader
# - Take 20-60 minutes depending on internet speed
```

**When prompted**, set root password.

---

## Step 11: Post-Install Setup

```bash
# Reboot
reboot
# Remove USB when system restarts

# First boot login as root
# Create your user (if not already in config)
useradd -m -G wheel,networkmanager,docker,libvirt fivelidz
passwd fivelidz

# Or login as your user if already configured
```

---

## Step 12: Verify System

```bash
# Check VRAM allocation
~/qalarc_OS/scripts/check-uma-allocation.sh

# Check ROCm
rocm-smi
rocminfo

# Start Ollama service
sudo systemctl start ollama
ollama list

# Test AI workspace
~/qalarc_OS/scripts/qalarc-ai-workspace.sh
```

---

## Post-Install: Download AI Models and Context

### AI Models (stored in /local-llms)

```bash
# Download Qwen2.5-Coder 32B (coding model)
ollama pull qwen2.5-coder:32b

# Download Llama 3.1 70B (general chat)
ollama pull llama3.1:70b

# Check models
ollama list

# Test inference
ollama run qwen2.5-coder:32b "Write a hello world in Rust"
```

### NixOS Context Library (stored in /context)

```bash
# Update NixOS documentation context
qalarc-nixos-update-context

# This downloads:
# - NixOS manual and wiki (~5GB)
# - Home Manager docs (~1GB)
# - Example configurations (~2GB)
# - Package cache (~500MB)

# Check context library status
qalarc-nixos-ai context

# Test NixOS AI assistant
qalarc-nixos-ai ask "How do I configure nginx?"

# Install MCP-NixOS for Claude Code
qalarc-nixos-install-mcp
```

**Storage after setup:**
- System: ~20GB (OS + apps)
- /local-llms: ~200GB (2 large models)
- /context: ~10GB (NixOS docs)
- **Remaining**: 9.7TB for more models and context!

---

## Troubleshooting

### Build fails during nixos-install
- **Check internet connection**: `ping google.com`
- **Check disk space**: `df -h /mnt/nix`
- **Check logs**: Last few lines will show error

### GRUB installation fails
- **Verify EFI partition**: `mount | grep boot`
- **Check if UEFI mode**: `ls /sys/firmware/efi` (should exist)
- **Reinstall**: `nixos-install --no-root-passwd --flake /mnt/home/qalarc_OS#gmktec-01`

### System won't boot after install
- **Boot from USB again**
- **Mount everything again** (Step 6)
- **Check hardware-configuration.nix**: Verify UUIDs match
- **Reinstall bootloader**: `nixos-enter` then `nixos-rebuild boot`

### ROCm not detecting GPU
- **Check BIOS**: Verify 96GB UMA VRAM setting
- **Check kernel params**: `cat /proc/cmdline` (should include `amd_pstate=active`)
- **Check HSA variable**: `echo $HSA_OVERRIDE_GFX_VERSION` (should be `11.5.1`)

### Ollama won't start
- **Check service**: `sudo systemctl status ollama`
- **Check logs**: `sudo journalctl -u ollama -f`
- **Manually test**: `/run/current-system/sw/bin/ollama serve`

---

## Next Steps After Installation

1. **Configure Neovim** with AI plugins (llama.vim, codecompanion.nvim)
2. **Set up Tailscale** for remote access: `sudo tailscale up`
3. **Download context library** via torrents
4. **Configure KDE Plasma** (tiling shortcuts with Krohnkite)
5. **Create first snapshot**: `sudo snapper -c root create --description "Fresh install"`
6. **Build custom installer ISO** (now that you have NixOS running):
   ```bash
   cd ~/qalarc_OS
   ./scripts/build-custom-iso.sh
   ```

---

## Documentation

- **Full installation guide**: `docs/INSTALLATION.md`
- **Design decisions**: `docs/DECISIONS.md`
- **AI software research**: `docs/AI-SOFTWARE-RESEARCH.md`
- **README**: `README.md`

---

## Support

If you encounter issues not covered here:
1. Check `docs/INSTALLATION.md` for detailed steps
2. Review NixOS manual: https://nixos.org/manual/nixos/stable/
3. Check qalarc_OS repository issues (GitHub)

**Remember**: BIOS must be configured for 96GB UMA VRAM BEFORE installing!
