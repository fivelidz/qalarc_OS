# qalarc_OS Installer UX Improvements

**Research Document: Pain Points from Manual NixOS Installation**

*Date: 2025-11-15*
*System: GMKTEC EVO-X2 AI (AMD Ryzen AI Max+ 395)*
*Current Method: Manual NixOS 24.11 installation*

---

## Executive Summary

This document tracks UX pain points encountered during manual NixOS installation to inform development of a user-friendly GUI installer for qalarc_OS.

**Goal:** Make qalarc_OS installation as easy as Ubuntu/Fedora while maintaining NixOS reproducibility.

---

## Installation Pain Points Log

### 1. Boot Menu Confusion
**Issue:** Multiple kernel options, unclear which to choose
- User saw: `nixos (linuxLTS)`, `nixos (linux 6.17.8)`, `options`, `memtest86+`, etc.
- Question: "Should I muck around with firmware setup?"
- **Confusion level:** Medium

**Solution for GUI Installer:**
- ✅ Auto-select newest kernel by default
- ✅ Hide advanced options behind "Advanced" button
- ✅ Clear recommendation: "Recommended for AMD Ryzen AI Max+"
- ✅ Tooltip explaining why newer kernel is better

---

### 2. Partitioning (gdisk) - MAJOR Pain Point
**Issue:** Manual command-line partitioning is confusing and error-prone

**Problems encountered:**
1. User didn't know what GPT was or why it's needed
2. Had to type cryptic commands: `o`, `n`, `ef00`, `8300`
3. Made mistake: typed `+1G` in "First sector" instead of "Last sector"
4. Had to delete and restart partition creation
5. Accidentally exited gdisk with Ctrl+C, had to re-enter
6. Unclear if 512M vs 1G was sufficient for boot partition

**User quote:** *"wtf why is this so complicated? I thought this would be able to boot easily from the USB?"*

**Confusion level:** HIGH ⚠️

**Solution for GUI Installer:**
- ✅ **Express Mode:** Single "Install" button with sane defaults
  - Auto-creates: 1GB EFI + remaining space BTRFS
  - No user input required
- ✅ **Custom Mode:** Visual disk layout with sliders
  - Drag slider for boot partition size (default: 1GB)
  - Visual preview of partition layout
  - Dropdown for filesystem type (not hex codes!)
- ✅ **Tooltips:**
  - "Boot partition: Stores bootloader and kernels (1GB recommended for snapshots)"
  - "System partition: Everything else (BTRFS with compression)"
- ✅ **Validation:** Prevent common mistakes before applying
- ✅ **Undo/Preview:** "Preview Changes" button before writing to disk

**Example UI Mock:**
```
┌─────────────────────────────────────────┐
│  Disk: /dev/nvme0n1 (2TB NVMe)         │
│                                         │
│  ┌─────┬────────────────────────────┐  │
│  │ EFI │ System (BTRFS)             │  │
│  │ 1GB │ 1.99TB                     │  │
│  └─────┴────────────────────────────┘  │
│                                         │
│  [◄────────────────────►] Boot: 1GB    │
│                                         │
│  ℹ BTRFS enables snapshots & rollback   │
│                                         │
│  [ Express Install ]  [ Custom... ]    │
└─────────────────────────────────────────┘
```

---

### 3. Root/Sudo Requirements Not Clear
**Issue:** User tried to run `gdisk /dev/nvme0n1` without sudo
- Error: "It says I have to open gdisk /dev/nvme0n1 as root or sudo?"
- **Confusion level:** Low (easily fixed)

**Solution for GUI Installer:**
- ✅ Launch installer with root privileges automatically
- ✅ Show authentication dialog at start: "qalarc_OS Installer needs admin access"
- ✅ No manual `sudo` commands needed

---

### 4. Uncertainty About Storage Size
**Issue:** User questioned if 512M was enough for boot partition
- Concern: "We will be doing snapper and such"
- Had to explain snapshots are stored separately

**Confusion level:** Medium

**Solution for GUI Installer:**
- ✅ Clear explanation of what goes where
- ✅ Recommended sizes with rationale:
  ```
  Boot Partition (EFI): 1GB
  ├─ Bootloader: ~10MB
  ├─ 5 kernel generations: ~500MB
  └─ Future updates: ~500MB reserve

  System Partition: Remaining space
  ├─ OS & applications: ~20GB
  ├─ Snapshots (6 months): ~30GB
  └─ User data & AI models: Rest
  ```

---

### 5. Command Feedback Unclear
**Issue:** After running format commands, output was minimal
- `mkfs.fat 4.2 (2021-01-31)` - is this success or error?
- `btrfs-progs v6.14` - what does this mean?

**Confusion level:** Low-Medium

**Solution for GUI Installer:**
- ✅ Progress bar with clear status:
  ```
  ✓ Creating partition table...        Done
  ✓ Formatting boot partition (FAT32)... Done
  ▶ Formatting system partition (BTRFS)... 45%
  ```
- ✅ Success checkmarks and clear messages
- ✅ Estimated time remaining

---

### 6. Multi-Drive Confusion
**Issue:** qalarc_OS documentation assumes 2 drives (2TB + 4TB)
- User only has 1 drive installed currently
- Had to adapt installation on the fly

**Confusion level:** Medium

**Solution for GUI Installer:**
- ✅ Auto-detect available drives
- ✅ Show different layouts based on hardware:
  - **1 drive detected:** Single-drive layout (everything on nvme0n1)
  - **2 drives detected:** Recommended layout (system on nvme0n1, models on nvme1n1)
- ✅ "You can add more drives later" note
- ✅ Dynamic configuration based on what's available

---

## Proposed Installer Features

### Must-Have (v1.0)
- [ ] **Express Install Mode**
  - One-click installation with sane defaults
  - Auto-partitioning, auto-formatting, auto-installation
  - User only chooses: username, password, hostname
  - Time to install: < 5 minutes of user interaction

- [ ] **Hardware Auto-Detection**
  - Detect VRAM allocation (warn if not 96GB)
  - Detect number of NVMe drives
  - Adapt installation layout automatically

- [ ] **Progress Visualization**
  - Clear progress bar for each step
  - Estimated time remaining
  - Success/failure indicators

- [ ] **Error Recovery**
  - Auto-retry on network failures
  - Clear error messages (not "Error code 1")
  - Suggestions for common problems

### Nice-to-Have (v2.0)
- [ ] **Custom Partitioning GUI**
  - Visual disk layout editor
  - Drag-to-resize partitions
  - Filesystem dropdown (BTRFS, ext4, XFS)
  - Encryption checkbox (LUKS)

- [ ] **Live Preview**
  - Preview system before installing
  - Try KDE Plasma before committing
  - Test WiFi/Bluetooth before install

- [ ] **Post-Install Wizard**
  - Download AI models during first boot
  - Configure Tailscale/remote access
  - Import SSH keys from GitHub/USB

### Advanced (v3.0)
- [ ] **Multi-System Installation**
  - Install qalarc_OS on multiple EVO-X2 systems
  - Network-based deployment (PXE boot)
  - Clone configuration from existing system

- [ ] **Offline Installation**
  - USB includes all packages (10-20GB ISO)
  - No internet required for base install
  - Download updates after first boot

---

## Technical Implementation Notes

### Installer Technology Stack Options

**Option 1: Calamares (Used by Manjaro, Fedora, etc.)**
- ✅ Mature, well-tested
- ✅ Qt-based (matches KDE Plasma)
- ✅ Modular (can customize for NixOS)
- ❌ Needs NixOS-specific modules

**Option 2: Custom NixOS Installer (nixos-anywhere + GUI)**
- ✅ Native NixOS integration
- ✅ Full control over UX
- ❌ More development work
- ❌ Maintenance burden

**Option 3: Web-based Installer (like Fedora Silverblue)**
- ✅ Modern UI (React/Vue)
- ✅ Easy to update (just HTML/JS)
- ❌ Requires running web server on ISO
- ❌ Less "native" feeling

**Recommendation:** Start with Calamares, extend with NixOS modules

---

## Installation Flow Comparison

### Current Manual Method (Pain)
```
1. Boot USB → 2 min wait
2. Login (nixos/nixos) → confusing
3. Test network (ping google.com) → manual
4. Partition (gdisk) → 10+ commands, easy to mess up
5. Format (mkfs.*) → 2 commands
6. Mount (mount) → 3+ commands
7. Generate config → 1 command
8. Edit config → manual file editing
9. Install → 1 command, 20 min wait
10. Reboot → manual
11. Configure qalarc_OS → many commands

Total time: 60+ minutes
User actions: 30+ commands
Confusion points: 6+
```

### Proposed GUI Method (Joy)
```
1. Boot USB → Auto-starts installer GUI
2. Welcome screen → Click "Install qalarc_OS"
3. Disk setup → Click "Express Install" (or customize)
4. User setup → Enter name, password, hostname
5. Review → Click "Install"
6. Installation progress → Wait 20 min (coffee break ☕)
7. Complete → Click "Reboot"
8. First boot wizard → Download AI models, configure network

Total time: 25-30 minutes
User actions: 5 clicks + typing credentials
Confusion points: 0
```

---

## Success Metrics

**Current experience (manual):**
- ⏱️ Time to bootable system: 60-90 minutes
- 📊 Success rate (first try): ~60% (guessing - need data)
- 😫 User frustration: High
- 🎓 Knowledge required: Linux command line, partitioning concepts

**Target experience (GUI installer):**
- ⏱️ Time to bootable system: < 30 minutes
- 📊 Success rate (first try): > 95%
- 😊 User frustration: Minimal
- 🎓 Knowledge required: None (can use mouse)

---

## Next Steps

1. **Complete this installation manually** - document all remaining pain points
2. **Analyze logs** - what questions came up? What failed?
3. **Create wireframes** - design GUI installer mockups
4. **Prototype with Calamares** - test NixOS module for qalarc_OS
5. **User testing** - have non-technical person try installer
6. **Iterate** - refine based on feedback

---

## Related Documents

- [QUICK-START.md](../QUICK-START.md) - Current manual installation guide
- [INSTALLATION.md](./INSTALLATION.md) - Detailed installation documentation
- [DECISIONS.md](./DECISIONS.md) - Design decisions for qalarc_OS

---

### 7. Mount Order Confusion - CRITICAL BUG ⚠️
**Issue:** Easy to mount partitions in wrong order, causing installation failure

**What happened:**
- User mounted system partition to `/mnt`
- Then mounted boot partition to `/mnt/boot`
- BUT the BTRFS partition somehow mounted to BOTH `/mnt` and `/mnt/boot`
- `nixos-install` failed with: "file system /boot is not a FAT EFI system"

**Root cause:** Unclear - possibly race condition or user mounted twice accidentally

**Confusion level:** HIGH ⚠️

**Solution for GUI Installer:**
- ✅ **Automatic mounting** - no manual commands
- ✅ **Validation before install:**
  ```
  Checking mount points...
  ✓ /mnt/boot is FAT32 EFI partition
  ✓ /mnt is BTRFS system partition
  ✓ UUIDs match expected partitions
  ```
- ✅ **Visual feedback:**
  ```
  Mounting partitions...
  ✓ /dev/nvme0n1p2 → /mnt (BTRFS)
  ✓ /dev/nvme0n1p1 → /mnt/boot (FAT32)
  ```
- ✅ **Automatic unmount/remount if wrong**

---

### 8. Installation Speed Confusion
**Issue:** Installation completed in seconds (suspicious)

**What happened:**
- First install attempt failed (mount issue)
- Second install attempt: completed in ~5 seconds
- User confused: "did it work?"

**Why it happened:** Nix cached packages from first attempt

**Confusion level:** Medium

**Solution for GUI Installer:**
- ✅ **Clear progress indication:**
  ```
  Installing NixOS...
  ✓ Cached packages found (3.2GB)
  ▶ Installing bootloader... (10%)
  ```
- ✅ **Explain what's happening:**
  - "Using cached packages from previous attempt"
  - "This is normal and saves time"
- ✅ **Show what's being installed even if cached**

---

### 9. USB Installer Limitations - MAJOR Issue ⚠️
**Issue:** Standard NixOS ISO is read-only, can't store custom files

**What happened:**
- User wanted to copy qalarc_OS to USB for offline install
- USB shows as 114GB but partition is only 1.6GB (ISO format)
- Partition is 100% full, read-only
- User quote: *"how is the USB full when the install is only 1.6GB and the USB is 114GB??"*

**Confusion level:** HIGH ⚠️

**Solution for custom qalarc_OS installer USB:**
- ✅ **Hybrid partitioning:**
  ```
  /dev/sda1: 3GB   - Bootable NixOS installer (ISO format)
  /dev/sda2: 111GB - Data partition (FAT32/ext4)
                     ├─ qalarc_OS/ (configs)
                     ├─ packages/ (cached Nix packages)
                     └─ optional-models/ (small AI models)
  ```
- ✅ **Offline installation capability**
- ✅ **Pre-loaded with all qalarc_OS files**
- ✅ **No internet required for base install**

**Implementation:** See `/home/fivelidz/projects/qalarc_OS/scripts/create-usb-installer.sh`

---

### 10. Drive Detection and Configuration - CRITICAL GAP ⚠️
**Issue:** qalarc_OS assumes 2 drives, no detection or adaptation

**What happened:**
- qalarc_OS QUICK-START.md expects:
  - nvme0n1 (2TB system drive)
  - nvme1n1 (4TB models/context drive)
- User only has nvme0n1 installed
- Config files reference non-existent `/local-llms` and `/context` mounts
- Installation would fail or require manual config editing

**User quote:** *"Surely there should be a prompt from qalarc_OS to ask how many drives we have? We need to configure this"*

**Confusion level:** CRITICAL ⚠️

**Solution for GUI Installer:**
- ✅ **Auto-detect drives at boot:**
  ```
  Detected hardware:
  ✓ nvme0n1 (1.8TB NVMe)
  ✗ nvme1n1 (not found)

  Recommended configuration:
  ○ Single drive (store everything on nvme0n1)
  ○ Wait for second drive (manual install later)
  ```
- ✅ **Dynamic directory structure:**
  - **1 drive:** `/local-llms` and `/context` as directories on main partition
  - **2 drives:** `/local-llms` and `/context` as separate mount points
- ✅ **Pre-configured profiles:**
  - `single-drive.nix` - Everything on one drive
  - `dual-drive.nix` - System + separate AI drive
  - `multi-drive.nix` - Advanced RAID/ZFS setups
- ✅ **Migration path:** Easy to add second drive later without reinstall

**Example UI:**
```
┌─────────────────────────────────────────┐
│  Storage Configuration                  │
│                                         │
│  Drives detected:                       │
│  ✓ nvme0n1 (1.8TB) - System drive      │
│  ✗ nvme1n1 (not detected)              │
│                                         │
│  Choose configuration:                  │
│  ● Single drive layout (recommended)   │
│    Everything on nvme0n1               │
│                                         │
│  ○ Wait for second drive               │
│    I'll add another drive before       │
│    installing                           │
│                                         │
│  [ Continue ]                           │
└─────────────────────────────────────────┘
```

---

### 11. Configuration File Complexity
**Issue:** User has to manually edit Nix files during installation

**What's required:**
- Copy auto-generated `hardware-configuration.nix`
- Edit `configuration.nix` to remove second-drive references
- Understand Nix syntax to comment out lines
- Know which lines are safe to remove

**User quote:** *"Can you just push to the github the alternative configuration files for a single drive, I can clone again and select the configuration file?"*

**Confusion level:** HIGH ⚠️

**Solution for future:**
- ✅ **Pre-built configurations:**
  - `hosts/gmktec-01-single-drive/` - 1 drive layout
  - `hosts/gmktec-01-dual-drive/` - 2 drive layout
  - Installer selects based on hardware detection
- ✅ **No manual editing required**
- ✅ **Flake with multiple outputs:**
  ```bash
  nixos-install --flake .#gmktec-01-single-drive
  # OR
  nixos-install --flake .#gmktec-01-dual-drive
  ```
- ✅ **Automatic hardware-configuration.nix generation** - no copying needed

---

## Installation Timeline (Actual Experience)

**Total time:** ~2 hours (mostly troubleshooting)

**User interaction required:**
- 40+ manual commands typed
- 3 error recovery situations
- Multiple "should I start over?" moments
- Manual file editing (not yet done)

**Emotional journey:**
- Start: Optimistic
- Partitioning: *"wtf why is this so complicated?"*
- Mount error: Frustration
- USB confusion: *"how is the USB full??"*
- Config mismatch: *"Surely there should be a prompt?"*

**This is exactly why we need a GUI installer!**

---

### 12. Hardcoded Username - Configuration Inflexibility ⚠️
**Issue:** Username is hardcoded in configuration files, not configurable during install

**What happened:**
- Configuration files hardcode username as "qalarc"
- User wanted to use this username, but it was coincidental
- No way to customize username during installation
- Had to manually edit multiple configuration files to change username

**User quote:** *"this should be able to be setup by new users though normally on install though right?"*

**Confusion level:** Medium-High

**Files affected:**
- `configuration.nix` - `users.users.qalarc`
- `systemd.tmpfiles.rules` - `/home/qalarc/local-llms`
- `snapper` modules - `ALLOW_USERS = [ "qalarc" ]`

**Solution for GUI Installer:**
- ✅ **Username prompt during installation:**
  ```
  ┌─────────────────────────────────────────┐
  │  User Account Setup                     │
  │                                         │
  │  Username: [____________]              │
  │            (letters, numbers, -, _)    │
  │                                         │
  │  Full name: [____________]             │
  │                                         │
  │  Password: [************]              │
  │  Confirm:  [************]              │
  │                                         │
  │  ☑ Add to wheel group (sudo access)   │
  │  ☑ Add to docker group                │
  │  ☑ Add to video/render groups         │
  │                                         │
  │  [ Continue ]                           │
  └─────────────────────────────────────────┘
  ```
- ✅ **Dynamic configuration generation:**
  - Replace `qalarc` with `${username}` in templates
  - Generate configuration files at install time
  - No hardcoded usernames in final config
- ✅ **Validation:**
  - Check username is valid (no spaces, special chars)
  - Check username doesn't conflict with system users
  - Password strength indicator

**Technical implementation:**
```nix
# Instead of hardcoded:
users.users.qalarc = { ... };

# Use variable substitution:
users.users.${config.qalarc.username} = { ... };

# Or generate from installer input:
users.users."${username}" = { ... };
```

---

### 13. Configuration File Errors - Duplicate Definitions ⚠️
**Issue:** Multiple NixOS modules had duplicate `environment.systemPackages` definitions

**What happened:**
- Five module files defined `environment.systemPackages =` twice in the same file
- NixOS build failed with "already defined" errors at multiple line numbers
- Error messages were cryptic: "lib/modules.nix:359:18", "lib/modules.nix:295:9"
- User had to wait through failed build to discover the issue

**Files with errors:**
- `modules/snapper/single-drive.nix` (line 8 and 103)
- `modules/media/default.nix` (line 6 and 66)
- `modules/networking/default.nix` (line 51 and 120)
- `modules/torrent/default.nix` (line 7 and 95)
- `modules/vpn-infrastructure/default.nix` (line 7 and 93)

**Confusion level:** CRITICAL ⚠️

**Root cause:**
- Modules were written separately, then had helper scripts added later
- Instead of appending to existing package list, new `environment.systemPackages =` blocks were created
- NixOS doesn't allow the same attribute to be assigned twice

**Solution for development:**
- ✅ **Pre-commit validation:**
  - Scan all .nix files for duplicate attribute definitions
  - Fail CI/CD if duplicates found
  - Suggest using `mkMerge` or combining into single list
- ✅ **Better error messages:**
  - NixOS should show: "environment.systemPackages defined at line 8 and line 103 in same file"
  - Instead of: "lib/modules.nix:359:18"
- ✅ **Linting tools:**
  - Use `nixpkgs-fmt` or `alejandra` to format code
  - Use `statix` to detect common NixOS mistakes
  - Add pre-commit hooks to catch errors before push

**Solution for GUI installer:**
- ✅ **Validate generated configurations before install:**
  ```
  Validating configuration...
  ✓ No duplicate definitions found
  ✓ All modules pass syntax check
  ✓ No conflicting options
  ```
- ✅ **Test build before actual install:**
  - Run `nixos-rebuild build` first (doesn't activate)
  - Only proceed to `nixos-rebuild switch` if build succeeds
  - Show clear error if validation fails

**Lesson learned:**
Configuration errors should be caught BEFORE the user tries to build, not during a 30-minute installation process.

---

---

### 14. No Pre-Build Validation - Catch Errors Late ⚠️
**Issue:** Configuration errors only discovered during 30+ minute build process

**What happened:**
- Multiple build attempts failed with cryptic error messages
- Each failure wasted 5-30 minutes before showing error
- Error messages like "1571:13" and "1083:7" with no context
- No way to validate configuration before starting build
- User quote: *"Is there anyway for you to detect these errors in advance?"*

**Confusion level:** CRITICAL ⚠️

**Current pain points:**
1. **Can't test on development machine** - CachyOS doesn't have Nix
2. **No pre-flight validation** - Can't run `nix flake check` before `nixos-rebuild`
3. **Slow failure feedback** - Have to wait for build to fail
4. **Cryptic error messages** - Line numbers without file names or context

**Solution - Pre-Build Validation System:**

✅ **1. GitHub Actions CI/CD:**
```yaml
# .github/workflows/validate.yml
name: Validate NixOS Configuration
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cachix/install-nix-action@v20
      - name: Check flake
        run: nix flake check
      - name: Build (don't install)
        run: |
          nix build .#nixosConfigurations.gmktec-01-single-drive.config.system.build.toplevel
```

✅ **2. Pre-commit hooks:**
```bash
# Install in repository
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
# Validate Nix files before commit
nix flake check || {
  echo "❌ Flake validation failed!"
  echo "Fix errors before committing"
  exit 1
}
EOF
chmod +x .git/hooks/pre-commit
```

✅ **3. Fast local validation script:**
```bash
# scripts/validate-config.sh
#!/bin/sh
echo "🔍 Validating NixOS configuration..."

# Check syntax
echo "  → Checking Nix syntax..."
find . -name "*.nix" -exec nix-instantiate --parse {} \; > /dev/null

# Check for common mistakes
echo "  → Checking for duplicate definitions..."
./scripts/check-duplicates.sh

# Check for missing packages
echo "  → Checking for undefined packages..."
nix flake check --no-build 2>&1 | grep "error:"

echo "✅ Validation complete!"
```

✅ **4. Duplicate detection script:**
```bash
# scripts/check-duplicates.sh
#!/bin/sh
# Detect duplicate attribute definitions

for file in $(find . -name "*.nix"); do
  # Check for duplicate environment.systemPackages
  count=$(grep -c "^  environment.systemPackages = " "$file")
  if [ "$count" -gt 1 ]; then
    echo "❌ $file has $count environment.systemPackages definitions"
    grep -n "environment.systemPackages = " "$file"
  fi

  # Check for duplicate systemd.tmpfiles.rules
  count=$(grep -c "^  systemd.tmpfiles.rules = " "$file")
  if [ "$count" -gt 1 ]; then
    echo "❌ $file has $count systemd.tmpfiles.rules definitions"
    grep -n "systemd.tmpfiles.rules = " "$file"
  fi
done
```

✅ **5. Better error reporting:**
Instead of:
```
error: 1571:13
error: 1083:7
```

Should show:
```
❌ Error in modules/ai-ml/default.nix:1571:13
   Package 'grub-btrfs' not found in nixpkgs

❌ Error in hosts/gmktec-01/configuration.nix:112:22
   Duplicate definition of 'environment.systemPackages'
   Already defined at line 8
```

**Implementation Priority:**
1. **Immediate**: Create `scripts/check-duplicates.sh` (5 min)
2. **Short-term**: Add GitHub Actions CI (30 min)
3. **Medium-term**: Improve NixOS error messages (upstream contribution)
4. **Long-term**: GUI installer with real-time validation

---

**Last updated:** 2025-11-16 00:45
**Status:** Investigating remaining build errors (1571:13, 1083:7)
