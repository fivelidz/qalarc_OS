# GMKTEC EVO-X2 Installation Session Summary

**Date:** 2025-01-16
**Hardware:** GMKTEC EVO-X2 AI (AMD Ryzen AI Max+ 395, 128GB RAM, 2TB NVMe)
**Configuration:** Single-drive setup (minimal boot)
**Result:** ✅ SUCCESS - KDE Plasma + SSH + Node.js installed

---

## Critical Hardware UUIDs (SAVED)

**Boot Partition (nvme0n1p1):**
- UUID: `3D3E-A87F`
- Type: FAT32 (EFI System Partition)
- Mount: `/boot`

**Root Partition (nvme0n1p2):**
- UUID: `8b606a67-2810-43cd-a6b7-b1cb3646b4d8`
- Type: BTRFS
- Mount: `/`

---

## Installation Timeline

### Phase 1: Base NixOS Installation
1. ✅ Network connectivity verified (ethernet)
2. ✅ Partitioned 2TB NVMe (1GB EFI + ~1.99TB system)
3. ✅ Formatted partitions (FAT32 boot, BTRFS root)
4. ✅ Mounted partitions and installed base NixOS
5. ✅ Set root password and rebooted

### Phase 2: qalarc_OS Configuration Attempts
1. ✅ Cloned qalarc_OS repository from GitHub
2. ❌ Attempted dual-drive config (only 1 drive installed)
3. ✅ Created single-drive variant
4. ❌ Multiple configuration errors (20+ cascading failures)
   - Duplicate systemd.tmpfiles.rules
   - Duplicate environment.systemPackages (5 modules)
   - grub-btrfs package missing
   - Username hardcoded
   - Ollama ROCm options unavailable
   - Python ML packages compatibility issues (numpy isILP64)

### Phase 3: Minimal Boot Configuration (SUCCESS)
1. ✅ Created minimal-boot branch with bare essentials
2. ✅ Fixed hardware-configuration.nix with actual UUIDs
3. ✅ Fixed /boot partition fsType (btrfs → vfat)
4. ✅ Successfully booted into KDE Plasma
5. ✅ Added Node.js and enabled flakes
6. ✅ Installed Claude Code

---

## Major Pain Points Documented

Total: **18 pain points** documented in [INSTALLER-UX-IMPROVEMENTS.md](./INSTALLER-UX-IMPROVEMENTS.md)

### Critical Issues (⚠️):
1. **#7** - Mount order confusion
2. **#18** - Hardware configuration UUID placeholders
3. **#6** - No multi-drive detection
4. **#13** - No pre-build validation

### High Impact:
- **#1** - Boot menu confusion
- **#2** - Partitioning complexity
- **#14** - No pre-build validation for errors
- **#15** - Package API changes between nixpkgs versions
- **#16** - Feature creep in initial install
- **#17** - Python ML package compatibility

---

## Final Working Configuration

**Branch:** `minimal-boot`
**Flake:** `gmktec-01-minimal`
**Location:** `/home/qalarc/qalarc_OS` (on GMKTEC)

**Installed Packages:**
- KDE Plasma 6
- SSH (enabled)
- Git
- Node.js 22
- Firefox
- Basic utilities (vim, wget, curl)

**Services Enabled:**
- SDDM (display manager)
- KDE Plasma desktop
- OpenSSH
- NetworkManager

---

## Rebuild Command (for future reference)

From `/home/qalarc/qalarc_OS`:

```bash
sudo mount /dev/nvme0n1p1 /boot  # If needed
sudo nixos-rebuild switch --flake .#gmktec-01-minimal --install-bootloader
```

Or with experimental features:

```bash
sudo nixos-rebuild switch --flake .#gmktec-01-minimal --option experimental-features "nix-command flakes"
```

---

## Next Steps (Phase 2)

1. **Change default password** from "qalarc"
2. **Install AI/ML stack** (after basic system is stable):
   - ROCm tools
   - Ollama
   - Python ML packages (via pip, not nixpkgs)
3. **Enable advanced features**:
   - Snapper snapshots
   - VPN infrastructure
   - Media tools
   - Torrent client
4. **Test SSH access** from main development machine
5. **Migrate to full qalarc_OS config** (gmktec-01-single-drive)

---

## Lessons Learned

### What Worked:
- ✅ "Do less first" philosophy - minimal config succeeded where full config failed
- ✅ Ethernet connectivity for network-based installs
- ✅ BTRFS for root filesystem (snapshots capability)
- ✅ Git workflow for configuration management
- ✅ Ctrl+D from emergency mode to continue boot

### What Didn't Work:
- ❌ Installing all features at once (feature creep)
- ❌ Python ML packages from nixpkgs 25.05 (API incompatibility)
- ❌ Copying hardware-configuration.nix between hosts (UUID placeholders)
- ❌ Assuming network is available in emergency mode
- ❌ Building without pre-validation of configuration

### Key Insights:
1. **Progressive enhancement** - Get basic desktop working FIRST
2. **UUID validation** - Always auto-detect, never use placeholders
3. **Pre-build validation** - Check for errors BEFORE building
4. **Package stability** - Use stable packages for initial install
5. **Emergency mode recovery** - Ctrl+D often works to continue boot

---

## Repository Status

**Main Branch:** Contains full qalarc_OS config (dual-drive + all modules)
**Minimal-Boot Branch:** Contains working minimal config (KDE + SSH only)

All pain points documented in: `docs/INSTALLER-UX-IMPROVEMENTS.md`
All changes pushed to: `https://github.com/fivelidz/qalarc_OS`

---

## Contact & Access

**GMKTEC System:**
- Hostname: `gmktec-minimal`
- IP: `192.168.1.39`
- User: `qalarc`
- SSH: Enabled (port 22)
- Desktop: KDE Plasma 6

**Development Machine:**
- Can SSH to GMKTEC for remote administration
- Claude Code installed on both systems

---

## Installation Time

**Total Time:** ~4 hours (manual install with troubleshooting)
**Target for GUI Installer:** < 30 minutes

**Time Breakdown:**
- Base NixOS install: 30 min
- qalarc_OS configuration attempts: 2.5 hours
- Troubleshooting and fixes: 1 hour
- Documentation: Ongoing

---

## Success Criteria Met

✅ NixOS installed and bootable
✅ KDE Plasma desktop working
✅ SSH enabled
✅ Network connectivity
✅ Node.js and Claude Code installed
✅ All pain points documented
✅ Hardware UUIDs saved
✅ Configuration in GitHub

**Status:** Ready for Phase 2 (AI/ML stack installation)
