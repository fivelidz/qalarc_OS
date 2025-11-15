# qalarc_OS Installation Guide

Complete step-by-step installation guide for NixOS on AMD Ryzen AI Max+ 395 systems (GMKTEC EVO-X2 AI).

**Target Hardware:** GMKTEC EVO-X2 AI, 128GB RAM, AMD Ryzen AI Max+ 395
**Installation Time:** 1-2 hours (depending on internet speed)
**Skill Level:** Intermediate (clear instructions provided)

---

## 📋 Pre-Installation Checklist

**Required:**
- ✅ GMKTEC EVO-X2 AI or compatible AMD Ryzen AI Max+ system
- ✅ 115GB USB drive (you have this!)
- ✅ Internet connection (Ethernet recommended, WiFi supported)
- ✅ Keyboard and monitor
- ✅ This guide

**Optional:**
- ⚪ Backup of any existing data (if upgrading from another OS)
- ⚪ Second computer for reference

---

## Phase 1: Create Bootable USB

### Step 1: Format and Prepare USB

**On your current CachyOS system:**

```bash
cd /home/fivelidz/projects/qalarc_OS

# Your USB is at: /run/media/fivelidz/2A42-1D95/
# Size: 115GB (perfect!)

# IMPORTANT: This will ERASE everything on the USB!
sudo ./scripts/create-usb-installer.sh /dev/sda
```

**The script will:**
1. Confirm you want to erase /dev/sda
2. Download NixOS 25.05 minimal ISO (~900MB)
3. Write ISO to USB
4. Show next steps

**Manual alternative (if script fails):**
```bash
# Download ISO
wget https://channels.nixos.org/nixos-25.05/latest-nixos-minimal-x86_64-linux.iso

# Write to USB
sudo dd if=nixos-25.05-minimal-x86_64-linux.iso of=/dev/sda bs=4M status=progress oflag=sync
sudo sync
```

---

## Phase 2: BIOS Configuration (Critical!)

### Step 2: Configure 96GB UMA VRAM

**Before installing NixOS, configure BIOS on the GMKTEC system:**

1. **Insert USB** into GMKTEC EVO-X2 AI
2. **Power on** and immediately press **F2** or **Del** (repeatedly)
3. **Navigate to:** Advanced → Graphics Configuration
4. **Find:** "Dedicated Graphics Memory" or "UMA Frame Buffer Size"
5. **Set to:** **96GB** (or maximum available)
6. **Save and Exit:** F10 → Yes

**Why this matters:**
- Enables 96GB VRAM for AI workloads
- Must be set BEFORE installing NixOS
- Kernel 6.16.9+ will auto-detect this setting
- Cannot be changed easily after installation

### Step 3: Boot from USB

1. **Reboot** GMKTEC system
2. Press **F12** (or F11/Esc for boot menu)
3. **Select:** USB device (shows as "USB HDD" or "UEFI: USB")
4. **Wait** for NixOS installer to boot (~30 seconds)

You should see a NixOS login prompt:
```
<<< Welcome to NixOS 25.05 (Warbler) - tty1 >>>

nixos login:
```

---

## Phase 3: NixOS Installation

### Step 4: Initial Setup in Installer

**Login as root** (no password needed):
```bash
nixos login: root
```

**Connect to internet:**

**Option A: Ethernet** (recommended)
```bash
# Should work automatically
ping -c 3 nixos.org
```

**Option B: WiFi**
```bash
systemctl start wpa_supplicant
wpa_cli

> add_network
0
> set_network 0 ssid "YourWiFiName"
OK
> set_network 0 psk "YourWiFiPassword"
OK
> enable_network 0
OK
> quit

# Test connection
ping -c 3 nixos.org
```

### Step 5: Partition Disk (BTRFS + LUKS Encryption)

**IMPORTANT:** This will erase your entire NVMe drive!

**Check your disk:**
```bash
lsblk
# You should see nvme0n1 (your main NVMe drive)
```

**Create partitions:**
```bash
# Use gdisk for GPT partitioning
gdisk /dev/nvme0n1

# Commands in gdisk:
o     # Create new GPT partition table
n     # New partition
1     # Partition number
      # Press Enter (default start)
+512M # 512MB for EFI
ef00  # EFI System partition

n     # New partition
2     # Partition number
      # Press Enter (default start)
      # Press Enter (use remaining space)
8300  # Linux filesystem

w     # Write changes
y     # Confirm
```

**Set up LUKS encryption** (optional but recommended):
```bash
# Encrypt the main partition
cryptsetup luksFormat /dev/nvme0n1p2

# You'll be asked to type YES (in capitals)
# Then enter your encryption password (REMEMBER THIS!)

# Open the encrypted partition
cryptsetup luksOpen /dev/nvme0n1p2 cryptroot
```

**Format partitions:**
```bash
# Format EFI partition
mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1

# Format main partition as BTRFS
mkfs.btrfs -L nixos /dev/mapper/cryptroot  # If encrypted
# OR
mkfs.btrfs -L nixos /dev/nvme0n1p2  # If not encrypted
```

### Step 6: Create BTRFS Subvolumes

**This is the qalarc_OS folder structure:**

```bash
# Mount the BTRFS filesystem
mount /dev/mapper/cryptroot /mnt  # If encrypted
# OR
mount /dev/nvme0n1p2 /mnt  # If not encrypted

# Create subvolumes
cd /mnt
btrfs subvolume create @
btrfs subvolume create @home
btrfs subvolume create @nix
btrfs subvolume create @local-llms
btrfs subvolume create @context
btrfs subvolume create @snapshots
btrfs subvolume create @var-log

cd /
umount /mnt
```

**Mount subvolumes with proper options:**

```bash
# Mount root subvolume
mount -o subvol=@,compress=zstd:3,noatime /dev/mapper/cryptroot /mnt

# Create mount points
mkdir -p /mnt/{home,nix,local-llms,context,.snapshots,var/log,boot}

# Mount other subvolumes
mount -o subvol=@home,compress=zstd:3,noatime /dev/mapper/cryptroot /mnt/home
mount -o subvol=@nix,noatime /dev/mapper/cryptroot /mnt/nix  # No compression for Nix store
mount -o subvol=@local-llms,compress=zstd:1,noatime /dev/mapper/cryptroot /mnt/local-llms
mount -o subvol=@context,compress=zstd:3,noatime /dev/mapper/cryptroot /mnt/context
mount -o subvol=@snapshots,noatime /dev/mapper/cryptroot /mnt/.snapshots
mount -o subvol=@var-log,compress=zstd:3,noatime /dev/mapper/cryptroot /mnt/var/log

# Mount EFI partition
mount /dev/nvme0n1p1 /mnt/boot
```

**Verify mounts:**
```bash
df -h
mount | grep /mnt
```

### Step 7: Clone qalarc_OS Configuration

**Install Git:**
```bash
nix-shell -p git
```

**Clone repository:**
```bash
cd /mnt/home
git clone https://github.com/fivelidz/qalarc_OS.git

# Create user directory
mkdir -p /mnt/home/qalarc
mv /mnt/home/qalarc_OS /mnt/home/qalarc/
```

### Step 8: Generate Hardware Configuration

```bash
# Generate hardware-configuration.nix
nixos-generate-config --root /mnt

# This creates:
# /mnt/etc/nixos/configuration.nix (we'll replace this)
# /mnt/etc/nixos/hardware-configuration.nix (we'll use this)
```

**Copy generated hardware config to qalarc_OS:**
```bash
cp /mnt/etc/nixos/hardware-configuration.nix \
   /mnt/home/qalarc/qalarc_OS/hosts/gmktec-01/hardware-configuration.nix
```

**Verify LUKS encryption is detected:**
```bash
cat /mnt/home/qalarc/qalarc_OS/hosts/gmktec-01/hardware-configuration.nix | grep -A 3 "luks"

# Should show something like:
# boot.initrd.luks.devices."cryptroot" = {
#   device = "/dev/nvme0n1p2";
# };
```

**If LUKS is not detected, add manually:**
```bash
nvim /mnt/home/qalarc/qalarc_OS/hosts/gmktec-01/hardware-configuration.nix

# Add before the fileSystems section:
boot.initrd.luks.devices."cryptroot" = {
  device = "/dev/nvme0n1p2";
};
```

### Step 9: Install NixOS

**Install from the qalarc_OS flake:**

```bash
nixos-install --flake /mnt/home/qalarc/qalarc_OS#gmktec-01
```

**This will:**
1. Download all packages (~5-10GB)
2. Build the system
3. Take 30-60 minutes depending on internet speed

**Set root password when prompted:**
```
setting root password...
New password: [enter password]
Retype new password: [enter password]
```

**Installation complete!**

```bash
# Unmount filesystems
umount -R /mnt

# Reboot
reboot
```

**Remove USB drive** when system restarts.

---

## Phase 4: Post-Installation Setup

### Step 10: First Boot

1. **GRUB menu** appears - select "NixOS"
2. **LUKS password** prompt (if encrypted) - enter your encryption password
3. **Login screen** (KDE Plasma SDDM)

**Login:**
- **User:** qalarc
- **Password:** [you need to set this - see below]

**IMPORTANT: Set user password:**

If you can't login (no password set):
1. Press **Ctrl+Alt+F2** (switch to TTY2)
2. Login as **root** with the password you set during installation
3. Set qalarc password:
   ```bash
   passwd qalarc
   ```
4. Press **Ctrl+Alt+F1** (back to GUI login)
5. Login as **qalarc**

### Step 11: Verify System

**Open terminal** (Konsole or Ghostty):

```bash
# Verify kernel version (should be 6.16.9+ for UMA auto-detection)
uname -r

# Check system info
cat /var/lib/qalarc/system-state.json | jq

# Verify 96GB VRAM allocation
cd ~/qalarc_OS
./scripts/check-uma-allocation.sh
```

**Expected output:**
```
✅ Kernel version supports automatic 96GB UMA detection
📈 Visible VRAM: 96GB
✅ 96GB UMA allocation is working correctly!
```

**If VRAM is not 96GB:**
- Reboot into BIOS (F2)
- Verify "Dedicated Graphics Memory" is set to 96GB
- Save and reboot

### Step 12: Initial Configuration

**Set up Ollama:**
```bash
# Ollama should be running already
sudo systemctl status ollama

# Pull a model (32B Qwen coder)
ollama pull qwen2.5-coder:32b

# This will download ~19GB - takes 10-20 minutes
```

**Set up Tailscale (remote access):**
```bash
sudo tailscale up

# Follow the URL to authenticate
# Your system will get a Tailscale IP (e.g., 100.64.x.y)
```

**Create first snapshot:**
```bash
# Create baseline snapshot
qalarc-snapshot "fresh-install"

# Verify
snapper list
```

**Launch AI workspace:**
```bash
qalarc-ai-workspace

# This opens TMUX with:
# - Qwen AI chat
# - System monitor (btop)
# - Command runner
```

---

## Phase 5: Customization & Testing

### Step 13: Test Core Features

**Test GPU acceleration:**
```bash
# Check ROCm
rocm-smi

# Check PyTorch ROCm
python3 -c "import torch; print(torch.cuda.is_available())"
# Should print: True

# Test llama.cpp with ROCm
ollama run qwen2.5-coder:32b "Write a hello world in Rust"
```

**Test snapshots:**
```bash
# Create a test file
echo "test" > ~/test.txt

# Create snapshot
qalarc-snapshot "test-snapshot"

# Delete file
rm ~/test.txt

# List snapshots
snapper list

# Restore file from snapshot
snapper rollback [snapshot-number]
```

**Test tiling (Krohnkite):**
- Open a few windows
- Press `Meta+T` to enable tiling
- Press `Meta+J/K/H/L` to navigate
- Press `Meta+Shift+J/K/H/L` to move windows

### Step 14: Customize Configuration

**Your config is in:**
```
~/qalarc_OS/
├── hosts/gmktec-01/configuration.nix  # Machine-specific
├── modules/                            # Feature modules
│   ├── desktop/default.nix
│   ├── ai-ml/default.nix
│   └── ...
└── overlays/performance.nix            # Optimizations
```

**Make changes:**
```bash
cd ~/qalarc_OS

# Edit a module
nvim modules/development/default.nix

# Add packages to environment.systemPackages

# Test changes (doesn't commit)
sudo nixos-rebuild test --flake .#gmktec-01

# If it works, apply permanently
sudo nixos-rebuild switch --flake .#gmktec-01

# Commit to git
git add -A
git commit -m "Add X package"
git push
```

**Use AI assistant to help:**
```bash
qalarc-ai-workspace

# In the AI chat:
"Help me add Docker to the development module"
"How do I configure a custom systemd service?"
```

---

## 🎯 Folder Structure Guide

**System folders:**
```
/                       Root (@ subvolume, snapshotted)
├── /home               User files (@home, snapshotted)
├── /nix                Nix store (@nix, NOT snapshotted, no compression)
├── /local-llms         AI models (@local-llms, minimal compression)
│   ├── ollama/         Ollama models
│   └── huggingface/    HF cache
├── /context            Context library (@context, snapshotted, compressed)
│   ├── github-repos/   Offline code repositories
│   ├── wikipedia/      Offline Wikipedia (future)
│   └── documentation/  Offline docs
├── /.snapshots         Snapper snapshots (@snapshots)
└── /var/log            Logs (@var-log, NOT snapshotted)
```

**User folders:**
```
/home/qalarc/
├── qalarc_OS/          Your NixOS configuration (THIS REPO)
├── Documents/
├── Downloads/
├── Pictures/
├── Videos/
├── Projects/           Your development projects
└── .config/            Application configs
```

---

## 🔧 Troubleshooting

### Issue: Can't boot into NixOS

**Solution:**
1. Boot from USB again
2. Mount your LUKS partition:
   ```bash
   cryptsetup luksOpen /dev/nvme0n1p2 cryptroot
   mount -o subvol=@ /dev/mapper/cryptroot /mnt
   mount /dev/nvme0n1p1 /mnt/boot
   ```
3. Chroot into system:
   ```bash
   nixos-enter --root /mnt
   ```
4. Fix issue and reinstall GRUB:
   ```bash
   nixos-rebuild boot --flake /home/qalarc/qalarc_OS#gmktec-01
   ```

### Issue: VRAM not 96GB

**Solution:**
1. Reboot into BIOS (F2)
2. Advanced → Graphics Configuration
3. Set "Dedicated Graphics Memory" to 96GB
4. Save and exit
5. Run: `./scripts/check-uma-allocation.sh`

### Issue: Ollama not starting

**Solution:**
```bash
# Check status
sudo systemctl status ollama

# Check logs
sudo journalctl -u ollama -f

# Restart
sudo systemctl restart ollama
```

### Issue: WiFi not working

**Solution:**
```bash
# Check network manager
sudo systemctl status NetworkManager

# Restart
sudo systemctl restart NetworkManager

# Use nmtui for GUI
nmtui
```

---

## 📚 Next Steps

**After installation:**

1. **Read documentation:**
   - [UMA-CONFIGURATION.md](./UMA-CONFIGURATION.md) - VRAM setup details
   - [LLM-SETUP.md](./LLM-SETUP.md) - AI model management
   - [REMOTE-ACCESS.md](./REMOTE-ACCESS.md) - VPN, SSH, streaming
   - [ARCHITECTURE.md](./ARCHITECTURE.md) - System design

2. **Customize your system:**
   - Add your favorite applications
   - Configure desktop environment
   - Set up development tools
   - Install AI models

3. **Test performance:**
   - Benchmark LLM inference
   - Compare to CachyOS baseline
   - Optimize as needed

4. **Join the community:**
   - Star the repo on GitHub
   - Share your customizations
   - Report issues

---

## 🎉 Installation Complete!

You now have a **production-ready NixOS system** optimized for AI/ML workloads!

**Key features working:**
✅ 96GB UMA VRAM for AI workloads
✅ Ollama with local models
✅ BTRFS snapshots with GRUB boot menu
✅ KDE Plasma 6 with tiling
✅ Tailscale for remote access
✅ AI coding workspace

**Start customizing:**
```bash
qalarc-ai-workspace  # Launch AI assistant
cd ~/qalarc_OS       # Edit configuration
```

**Need help?** Check `/var/lib/qalarc/system-state.json` for system info or ask the AI assistant!

---

**Last Updated:** 2025-11-15
**Installation Guide Version:** 1.0
**Tested On:** GMKTEC EVO-X2 AI (AMD Ryzen AI Max+ 395)
