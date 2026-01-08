# qalarc_OS Fresh Install Guide

## Lessons Learned from GMKTEC EVO-X1 Installation (2026-01-06)

This document captures all issues encountered and their solutions for future fresh installs.

---

## Pre-Installation Checklist

### BIOS Settings (Critical)
1. **Graphics Memory**: Advanced → Graphics → Dedicated Memory = **96GB**
   - This allocates 96GB of the 128GB RAM to the Radeon 8060S iGPU
   - Leaves 32GB for system RAM
   - Required for running 70B+ LLMs locally

### USB Installer Issues

#### Issue 1: Symlink Instead of File Copy
**Problem**: `quick-install.sh` creates symlinks instead of copying actual files.
```
/mnt/home/qalarc/qalarc_OS -> /etc/static/qalarc_OS  # WRONG - symlink to read-only ISO
```

**Fix**: Use `cp -rL` instead of `cp -r` to dereference symlinks:
```bash
# In scripts/quick-install.sh
sudo cp -rL /etc/qalarc_OS /mnt/home/qalarc/qalarc_OS
sudo chmod -R u+w /mnt/home/qalarc/qalarc_OS
```

---

## NixOS 25.05 Package Changes

### Renamed/Moved Packages
| Old Name | New Name | Notes |
|----------|----------|-------|
| `nvtop` | `nvtopPackages.amd` | AMD-specific version |
| `gwenview` | `kdePackages.gwenview` | KDE apps moved |
| `kdenlive` | `kdePackages.kdenlive` | KDE apps moved |
| `okular` | `kdePackages.okular` | KDE apps moved |
| `noto-fonts-cjk` | `noto-fonts-cjk-sans` | Font renamed |
| `python312Packages.uvx` | `uv` | Package restructured |

### Nerd Fonts Restructured
**Old** (broken):
```nix
(nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Hack" ]; })
```

**New** (working):
```nix
nerd-fonts.fira-code
nerd-fonts.jetbrains-mono
nerd-fonts.hack
```

### Removed Packages
- `kdePackages.kwin-bismuth` - Not available in 25.05, comment out

### Deprecated Options
| Old Option | New Option |
|------------|------------|
| `services.xserver.libinput.enable` | `services.libinput.enable` |
| `hardware.pulseaudio.enable` | `services.pulseaudio.enable` |

---

## Kernel Issues

### CachyOS Kernel Problem
**Goal**: Use CachyOS kernel for 20-30% performance improvement (BORE scheduler, AMD optimizations)

**Problem**: CachyOS kernel from chaotic-nyx builds all drivers as built-in (`CONFIG_*=y`) instead of modules (`CONFIG_*=m`). NixOS initrd builder requires modules for shrinking.

**Error**:
```
error: builder for 'linux-6.17.9-modules-shrunk.drv' failed
Can not derive a closure of kernel modules because no modules were provided.
```

### Potential Solutions

#### Option 1: Disable initrd module shrinking (UNTESTED)
```nix
boot.initrd.systemd.enable = true;
boot.initrd.systemd.emergencyAccess = true;
# May need additional configuration
```

#### Option 2: Use standard kernel with performance params
```nix
boot.kernelPackages = pkgs.linuxPackages_latest;
boot.kernelParams = [
  "amd_pstate=active"
  "mitigations=off"  # Only if security is less concern
  "nowatchdog"
  "nmi_watchdog=0"
];
```

#### Option 3: Build custom CachyOS-like kernel (RECOMMENDED for future)
Create a custom kernel package that:
1. Uses CachyOS patches/config
2. Keeps essential drivers as modules
3. Works with NixOS initrd

### Current Workaround
Using `linuxPackages_latest` (mainline 6.17.8) instead of CachyOS. Works but loses ~20-30% performance.

---

## BLAS/numpy Error

**Error**:
```
error: attribute 'isILP64' missing at numpy/2.nix
```

**Cause**: Direct MKL override in performance overlay breaks numpy.

**Bad** (in `overlays/performance.nix`):
```nix
blas = super.mkl;
lapack = super.mkl;
```

**Fix**: Remove direct BLAS/LAPACK override. Let nixpkgs handle it.

---

## SSH Configuration

### Issue: Password Auth Disabled After Rebuild
The `modules/networking/default.nix` has:
```nix
PasswordAuthentication = false;  # Locks out remote access
```

**Fix**: Either enable password auth or add SSH keys to user config:
```nix
users.users.qalarc = {
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAA... user@host"
  ];
};
```

---

## Service Issues

### network-status-export Service
**Error**: `env: 'qalarc-network-status': No such file or directory`

**Cause**: Using `env` instead of full path.

**Fix** in `modules/networking/default.nix`:
```nix
systemd.services.network-status-export = {
  serviceConfig = {
    ExecStart = "/run/current-system/sw/bin/qalarc-network-status";
    StandardOutput = "file:/var/lib/qalarc/network-status.json";
  };
};

# Also add tmpfiles rule:
systemd.tmpfiles.rules = [
  "d /var/lib/qalarc 0755 root root -"
];
```

---

## Missing Essential Apps

### Apps to Add
- [ ] Signal Desktop
- [ ] Ollama (uncomment in ai-ml module or use ai-ml-enhanced)
- [ ] Discord (if needed)
- [ ] Slack (if needed)
- [ ] 1Password or Bitwarden
- [ ] VLC
- [ ] OBS Studio
- [ ] Spotify

### To add Signal:
```nix
# In modules/desktop/default.nix or similar
environment.systemPackages = with pkgs; [
  signal-desktop
];
```

---

## ROCm Verification

After install, verify ROCm with:
```bash
# Check ROCm detects hardware
rocminfo

# Expected output should show:
# Agent 1: AMD RYZEN AI MAX+ 395 (CPU)
# Agent 2: gfx1151 (GPU - Radeon 8060S)

# Check VRAM allocation
cat /sys/class/drm/card*/device/mem_info_vram_total
# Should show: 103079215104 (96GB)
```

---

## Post-Installation Checklist

- [ ] System boots to correct GRUB entry
- [ ] LUKS password accepted
- [ ] Login as qalarc user works
- [ ] Network connectivity (Ethernet/WiFi)
- [ ] SSH access from remote machines
- [ ] ROCm detects GPU with 96GB VRAM
- [ ] Desktop environment (KDE Plasma) starts
- [ ] Docker service running
- [ ] Tailscale connected
- [ ] Ollama service running (if enabled)

---

## Quick Recovery Commands

If SSH is locked out:
```bash
# From console, add SSH key
mkdir -p ~/.ssh
echo 'ssh-ed25519 AAAA... user@host' >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys
```

If wrong boot entry selected:
```bash
# Force rebuild to set default boot
sudo nixos-rebuild boot --flake ~/qalarc_OS#gmktec-01
sudo reboot
```

---

## Files Modified During This Install

1. `hosts/gmktec-01/configuration.nix`
   - Changed `linuxPackages_cachyos` → `linuxPackages_latest`
   - Fixed `hardware.pulseaudio.enable` → `services.pulseaudio.enable`
   - Added SSH authorized keys

2. `modules/networking/default.nix`
   - Enabled `PasswordAuthentication = true`
   - Fixed network-status-export service
   - Added tmpfiles rule for /var/lib/qalarc

3. `modules/desktop/default.nix`
   - Fixed nerdfonts syntax
   - Fixed `services.xserver.libinput.enable` → `services.libinput.enable`
   - Commented out `kwin-bismuth`
   - Fixed `noto-fonts-cjk` → `noto-fonts-cjk-sans`

4. `modules/system-monitor/default.nix`
   - Fixed `nvtop` → `nvtopPackages.amd`

5. `modules/media/default.nix`
   - Fixed `gwenview` → `kdePackages.gwenview`
   - Fixed `kdenlive` → `kdePackages.kdenlive`
   - Fixed `okular` → `kdePackages.okular`

6. `modules/nixos-ai-assistant/default.nix`
   - Fixed `python312Packages.uvx` → `uv`

7. `overlays/performance.nix`
   - Removed `blas = super.mkl; lapack = super.mkl;`
   - Removed ffmpeg-full override (vaapiSupport args changed)
