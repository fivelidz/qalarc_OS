# qalarc_OS USB Installer

Interactive installer system for creating custom qalarc_OS installation media.

---

## Overview

This installer provides a user-friendly way to create custom qalarc_OS installations with profile selection, hardware detection, and automated configuration.

### Features

- **Profile-Based Installation**: Choose from AI Workstation, Gaming+AI, or Base profiles
- **Hardware Detection**: Automatic detection of CPU, GPU, RAM, and VRAM
- **Interactive Menus**: Dialog-based UI for easy navigation
- **Modular Configuration**: Toggle features and packages based on needs
- **ISO Generation**: Create bootable USB installation media
- **VRAM Verification**: Checks for optimal AI configuration (96GB VRAM)

---

## Quick Start

### Build Installation ISO

```bash
cd ~/projects/usb-installer
./build-iso.sh
```

This will:
1. Create a flake.nix configuration
2. Build the ISO using nixos-generators
3. Output to `./output/qalarc-os-YYYYMMDD.iso`
4. Generate SHA256 checksum

### Write to USB

```bash
# Find your USB device
lsblk

# Write ISO (replace /dev/sdX with your USB device)
sudo dd if=./output/qalarc-os-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

---

## Installation Profiles

### AI Workstation (Recommended)

**Best for**: AI/ML development, research, LLM inference

**Includes**:
- ROCm GPU acceleration
- Ollama + oterm (local LLM)
- Open WebUI (model management)
- Python ML stack (PyTorch, Transformers)
- llama.cpp for GGUF models
- Complete development environment
- Docker + containers
- BTRFS snapshots

**VRAM Recommendation**: 96GB for large models (70B+)

---

### Gaming + AI

**Best for**: Gaming enthusiasts who also want AI tools

**Includes**:
- Everything from AI Workstation PLUS:
- Steam with Proton
- Lutris (Epic, GOG)
- Heroic Games Launcher
- GameMode optimization
- MangoHud performance overlay
- ProtonUp-Qt
- Wine + Winetricks
- Discord

**Hardware**: Optimized for AMD APU gaming + AI workloads

---

### Base System

**Best for**: Custom builds, servers, minimal installations

**Includes**:
- KDE Plasma 6 desktop
- Core development tools
- Basic utilities
- BTRFS snapshots
- Minimal package set

**Customization**: Add features manually after installation

---

## File Structure

```
usb-installer/
├── installer.sh           # Main interactive installer
├── detect-hardware.sh     # Hardware detection script
├── build-iso.sh          # ISO generation script
├── profiles/             # Installation profiles
│   ├── ai-workstation.nix
│   ├── gaming-ai.nix
│   └── base.nix
├── modules/              # Optional feature modules
├── templates/            # Configuration templates
├── flake.nix            # Generated during ISO build
└── output/              # Built ISOs and checksums
```

---

## Hardware Detection

The `detect-hardware.sh` script detects:

- CPU model and vendor (checks for AMD Ryzen AI MAX+)
- Total system RAM
- GPU model (checks for AMD)
- VRAM allocation (critical for AI workloads)
- Disk configuration
- Compatibility status

### Usage

```bash
# Human-readable output
./detect-hardware.sh --human

# JSON output (for scripts)
./detect-hardware.sh --json
```

### VRAM Status Levels

- **Excellent (90GB+)**: Can run 70B+ parameter models
- **Good (60-89GB)**: Can run up to 70B models
- **Moderate (30-59GB)**: Recommended for up to 33B models
- **Low (<30GB)**: BIOS configuration needed

---

## Installation Workflow

### 1. Boot from USB

- Insert USB drive
- Boot system and select USB in BIOS
- Wait for qalarc_OS installer to load

### 2. Run Installer

```bash
qalarc-install
```

### 3. Profile Selection

Choose your desired profile:
- AI Workstation (recommended for this hardware)
- Gaming + AI
- Custom (select individual modules)

### 4. Hardware Detection

Installer automatically detects and verifies:
- CPU compatibility
- GPU detection
- RAM availability
- VRAM allocation status

### 5. System Configuration

Enter:
- Hostname (default: qalarc-workstation)
- Username (default: qalarc)
- Target disk for installation

### 6. Confirmation

Review installation summary and confirm

### 7. Installation

- Disk partitioning (EFI + BTRFS)
- NixOS installation
- Configuration deployment
- User setup

### 8. First Boot

After reboot:
- qalarc_OS Welcome Window launches automatically
- Follow guided setup for:
  - Hardware verification
  - AI model downloads
  - System tour
  - Status monitoring

---

## Customization

### Modify Profiles

Edit profile files in `profiles/` directory:

```nix
# Add packages to ai-workstation.nix
environment.systemPackages = with pkgs; [
  # Add your packages here
  yourPackage
];
```

### Create Custom Modules

Add new `.nix` files to `modules/` directory:

```nix
# modules/my-feature.nix
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    package1
    package2
  ];
}
```

---

## Advanced Usage

### Manual Installation

For experts who want full control:

1. Boot from USB
2. Use standard NixOS installation process
3. Copy desired profile from `profiles/` to `/mnt/etc/nixos/`
4. Modify as needed
5. Run `nixos-install`

### Testing in VM

```bash
# QEMU
qemu-system-x86_64 \
  -cdrom output/qalarc-os-*.iso \
  -boot d \
  -m 4G \
  -enable-kvm

# Or use virt-manager GUI
```

---

## Troubleshooting

### ISO Build Fails

**Error**: `nix build failed`

**Solution**:
- Ensure you're on NixOS
- Check `flake.nix` syntax
- Try: `nix flake check`

### Hardware Not Detected

**Error**: Hardware detection returns zeros

**Solution**:
- Run as root: `sudo ./detect-hardware.sh`
- Check if ROCm tools are available
- Verify BIOS VRAM allocation

### Installer Won't Start

**Error**: `dialog` not found

**Solution**:
- Installer loads `dialog` automatically
- If fails, try: `nix-shell -p dialog`

---

## Portable Installation

### What is a Portable Installation?

A **portable installation** allows qalarc_OS to boot from an external drive (USB, external SSD) on different computers. This is useful for:

- **Testing** qalarc_OS without modifying your main system
- **Mobile workstation** - carry your complete AI environment between machines
- **Demonstrations** - show qalarc_OS on different hardware
- **Development** - test configurations across multiple systems

### Requirements

**Hardware**:
- External drive (USB 3.0+, external NVMe/SSD recommended)
- Minimum 64GB capacity (128GB+ recommended)
- Fast drive for good performance (NVMe > SSD > USB 3.0 > USB 2.0)

**Target Computers**:
- AMD CPU (preferably Ryzen AI MAX+)
- AMD GPU for ROCm acceleration
- 32GB+ RAM
- UEFI boot support
- USB boot enabled in BIOS

### How It Works

The installer **automatically detects** removable drives and offers portable installation:

```bash
=== Portable Installation Detection ===

Target disk: /dev/sdb
Analysis: Removable drive with sufficient capacity (256GB)

✓ This drive is suitable for portable installation!

Portable installation allows qalarc_OS to boot on different computers
from this external drive.

Configure as portable installation? [Y/n]:
```

### Portable vs. Standard Installation

| Feature | Standard | Portable |
|---------|----------|----------|
| **Performance** | Optimized for specific hardware | Generic, broader compatibility |
| **Hardware Detection** | Uses specific device names | Uses UUIDs for stability |
| **Kernel** | Hardware-specific optimizations | Generic x86_64 |
| **Drivers** | Minimal (specific hardware) | Comprehensive (various hardware) |
| **Portability** | Fixed to one machine | Boots on multiple machines |
| **VRAM Config** | Can use BIOS-specific settings | Must detect on each boot |

### Installation Steps

1. **Plug in External Drive** (64GB+ recommended)

2. **Boot Installation Media**

3. **Run Installer**:
   ```bash
   qalarc-install
   ```

4. **Select Profile** (AI Workstation recommended)

5. **Choose External Drive**:
   ```
   Available disks:
   sda  931.5G  disk    # Internal drive (skip this)
   sdb  256G    disk    # External USB/SSD (select this)
   ```

6. **Confirm Portable Installation**:
   - Installer auto-detects removable drive
   - Prompts to configure as portable
   - Press Y to enable

7. **Complete Installation**

### Using Portable qalarc_OS

#### On New Computer

1. **Plug in External Drive**

2. **Enter BIOS** (F2/Del during boot)

3. **Set Boot Order**:
   - Move USB/External drive to first position
   - Or use Boot Menu (F12) to select drive

4. **Boot qalarc_OS**:
   - System will boot from external drive
   - Hardware detection runs automatically
   - AI tools available after boot

#### VRAM Configuration

**Important**: VRAM allocation is BIOS-specific:

- **First Boot on New Computer**: May have limited VRAM
- **To Enable 96GB VRAM**:
  1. Follow BIOS guide on that specific computer
  2. Set UMA Frame Buffer to 96GB
  3. Reboot

- **On Each Computer**: VRAM settings are per-machine
- **Portable Mode**: Detects available VRAM automatically

#### Performance Considerations

**Fast External Drives** (NVMe/SSD):
- Boot time: ~20-40 seconds
- Performance: 80-95% of internal drive
- Recommended for daily use

**USB 3.0 Drives**:
- Boot time: ~40-90 seconds
- Performance: 50-80% of internal drive
- Acceptable for testing/demos

**USB 2.0 Drives**:
- Boot time: 2-5 minutes
- Performance: 20-40% of internal drive
- Not recommended

### Limitations

**Not Recommended For**:
- ❌ Large model training (slow I/O)
- ❌ Intensive database workloads
- ❌ Primary production system

**Works Well For**:
- ✅ AI inference (models loaded to RAM)
- ✅ Development and testing
- ✅ Demonstrations
- ✅ Mobile workstation

### Troubleshooting

#### Won't Boot on New Computer

**Issue**: External drive not recognized

**Solutions**:
- Check BIOS boot order
- Enable USB boot in BIOS
- Disable Secure Boot (temporarily)
- Try different USB port (USB 3.0 ports)

#### Limited VRAM on New Computer

**Issue**: Only 2GB VRAM detected instead of 96GB

**Solution**: Configure BIOS on that specific computer:
```bash
# After boot, check current VRAM
rocm-smi --showmeminfo vram

# If low, follow BIOS guide to set 96GB
cat ~/Documents/qalarc-os-setup/BIOS-SETUP-GUIDE.md
```

#### Slow Performance

**Issue**: System feels sluggish

**Causes & Solutions**:
- **USB 2.0 Drive**: Upgrade to USB 3.0+ or SSD
- **Fragmented Drive**: Reinstall on fresh drive
- **Slow Computer**: Check host CPU/RAM specs
- **Background I/O**: Load models to RAM first

#### Hardware Not Detected

**Issue**: GPU or devices not recognized

**Solution**: Portable mode includes fallback drivers, but some exotic hardware may need manual configuration:

```bash
# Check what was detected
lspci | grep -i vga
rocminfo

# May need to rebuild with specific drivers
```

---

## VRAM Configuration

### Why 96GB VRAM Matters

AMD Ryzen AI MAX+ systems can allocate up to 96GB of system RAM as VRAM (UMA Frame Buffer). This is critical for running large AI models.

### How to Configure

**In BIOS** (during or after installation):
1. Press F2/Del during boot
2. Navigate to: Advanced → Graphics Configuration
3. Set "Dedicated Graphics Memory" or "UMA Frame Buffer Size" to **96GB**
4. Save and reboot

**Verification** (after boot):
```bash
rocm-smi --showmeminfo vram
# Should show ~96GB
```

**Guide**: Full instructions in `~/Documents/qalarc-os-setup/BIOS-SETUP-GUIDE.md`

---

## Next Steps After Installation

1. **Verify Hardware**:
   ```bash
   rocm-smi --showmeminfo vram
   rocminfo | grep -i vram
   ```

2. **Update VRAM** (if needed):
   - Follow BIOS guide
   - Reboot and verify

3. **Download AI Models**:
   ```bash
   ollama pull llama3.3:70b
   ollama pull deepseek-coder:33b
   ```

4. **Launch AI Tools**:
   ```bash
   oterm                    # Terminal UI
   # Or visit http://localhost:8080  # Web UI
   ```

5. **Explore System**:
   - Terminal: `ghostty`
   - File Manager: `dolphin ~/projects`
   - Documentation: `~/Documents/qalarc-os-setup/`

---

## Resources

- **qalarc_OS Documentation**: `~/claude/OM/`
- **Project Ideas**: `~/claude/OM/ideas/`
- **BIOS Guide**: `~/Documents/qalarc-os-setup/BIOS-SETUP-GUIDE.md`
- **Phase 7 Summary**: `~/Documents/qalarc-os-setup/PHASE7-COMPLETE-SUMMARY.md`
- **Model Database**: `~/projects/model-manager/model-database.json`

---

## Support

For issues or questions:
- Check documentation in `~/Documents/qalarc-os-setup/`
- Review phase summaries in `~/Documents/`
- Examine logs in `/var/log/`

---

**Version**: 1.0.0
**Last Updated**: 2025-11-17
**Compatible With**: NixOS 25.05+
**Hardware**: AMD Ryzen AI MAX+ series
