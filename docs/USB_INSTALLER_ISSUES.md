# qalarc_OS USB Installer Issues & Solutions

This document captures issues discovered during the initial qalarc_OS installation
on a GMKTEC EVO-X1 AI system, along with their solutions for improving the USB installer.

## Installation Date: 2026-01-06

---

## Issue 1: Symlink Instead of File Copy from ISO

### Problem
When the installer script copies `qalarc_OS` from the live ISO to the target system,
it creates a symlink instead of copying the actual files:

```
/mnt/home/qalarc/qalarc_OS -> /etc/static/qalarc_OS
```

The `/etc/static/qalarc_OS` path is read-only on the squashfs live ISO, causing
`nixos-install` to fail when it tries to write or modify configuration files.

### Root Cause
The `quick-install.sh` script uses `cp -r` which preserves symlinks from the source.
On the NixOS live ISO, `/etc/qalarc_OS` itself is a symlink managed by the activation
system, so `cp -r` copies the symlink rather than the target files.

### Solution
Update `quick-install.sh` to use `cp -rL` instead of `cp -r`:

```bash
# Before (broken):
sudo cp -r /etc/qalarc_OS /mnt/home/qalarc/qalarc_OS

# After (fixed):
sudo cp -rL /etc/qalarc_OS /mnt/home/qalarc/qalarc_OS
```

The `-L` flag dereferences symlinks, copying the actual files instead of the symlinks.

### Additional Fix
Also ensure the copied files are writable:
```bash
sudo chmod -R u+w /mnt/home/qalarc/qalarc_OS
```

---

## Issue 2: BLAS/numpy isILP64 Error in AI-ML Module

### Problem
When running `nixos-install --flake .#gmktec-01`, the build failed with:

```
error: attribute 'isILP64' missing
       at /nix/store/.../numpy/2.nix
```

This error occurs in the Python/numpy package configuration related to BLAS library selection.

### Root Cause
The AI-ML module (`modules/ai-ml/default.nix`) has a configuration issue with the
BLAS (Basic Linear Algebra Subprograms) library settings. The numpy package is
trying to access an `isILP64` attribute that doesn't exist in the current package set.

### Workaround
Use the `gmktec-01-minimal` configuration instead:
```bash
nixos-install --flake /mnt/home/qalarc/qalarc_OS#gmktec-01-minimal --no-root-passwd
```

### Permanent Fix Needed
Review and fix the AI-ML module configuration:
1. Check `modules/ai-ml/default.nix` for BLAS/numpy configuration
2. Ensure proper `blas` and `lapack` provider settings
3. May need to pin specific numpy version or BLAS implementation
4. Test with ROCm packages on AMD hardware

---

## Issue 3: Hardware Configuration Not Generated

### Problem
The installer script may not properly generate the hardware configuration file
before attempting to install, leading to missing device UUIDs or partition information.

### Solution
Ensure `nixos-generate-config` is run before attempting install:

```bash
# Generate hardware config from mounted system
nixos-generate-config --root /mnt

# Copy to the correct host directory
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/qalarc/qalarc_OS/hosts/gmktec-01/hardware-configuration.nix
```

This should already be in `quick-install.sh` but verify it runs correctly.

---

## Issue 4: Auto-Installer Feedback

### Problem
When the auto-installer runs after boot, it performs many operations (chmod on modules)
but doesn't provide clear status feedback to the user. If something fails, the user
is returned to a prompt without understanding what went wrong.

### Solution
1. Add more verbose progress indicators to `quick-install.sh`
2. Add error trapping with clear error messages
3. Consider logging all output to a file for debugging:

```bash
exec > >(tee -a /tmp/qalarc-install.log) 2>&1
```

---

## Issue 5: Network Setup Timing

### Problem
User may not have network connectivity when installer auto-runs, and the
original script didn't automatically prompt for WiFi setup.

### Solution (Already Applied)
The `quick-install.sh` `check_network()` function was updated to:
1. Check for network connectivity first
2. If no connection, automatically launch `nmtui` for WiFi setup
3. Provide retry options if connection still fails

---

## Quick Reference: Manual Recovery Steps

If the auto-installer fails, these are the manual recovery steps via SSH:

```bash
# 1. SSH into the live system (via Thunderbolt or network)
ssh nixos@169.254.45.117  # password: nixos

# 2. Check mount status
lsblk
mount | grep /mnt

# 3. Fix symlink issue if present
ls -la /mnt/home/qalarc/qalarc_OS
# If it shows a symlink, fix it:
sudo rm /mnt/home/qalarc/qalarc_OS
sudo cp -rL /etc/qalarc_OS /mnt/home/qalarc/qalarc_OS
sudo chmod -R u+w /mnt/home/qalarc/qalarc_OS

# 4. Generate hardware config
sudo nixos-generate-config --root /mnt
sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/qalarc/qalarc_OS/hosts/gmktec-01/hardware-configuration.nix

# 5. Run install (use gmktec-01-minimal if full config fails)
sudo nixos-install --flake /mnt/home/qalarc/qalarc_OS#gmktec-01-minimal --no-root-passwd

# 6. Set passwords
sudo nixos-enter --root /mnt -c "passwd qalarc"
sudo nixos-enter --root /mnt -c "passwd root"

# 7. Reboot (remove USB first)
sudo reboot
```

---

## Files to Update for USB Installer Fix

1. **`/home/fivelidz/projects/qalarc_OS/scripts/quick-install.sh`**
   - Change `cp -r` to `cp -rL` when copying qalarc_OS
   - Add `chmod -R u+w` after copy
   - Add better error handling and logging

2. **`/home/fivelidz/projects/qalarc_OS/modules/ai-ml/default.nix`**
   - Fix BLAS/numpy configuration
   - Test with ROCm packages

3. **`/home/fivelidz/projects/qalarc_OS/installer/iso-config.nix`**
   - Consider adding rescue/debug option to skip auto-installer

---

## Post-Installation Checklist

After successful installation, verify:

- [ ] System boots and accepts LUKS password
- [ ] Can login as `qalarc` user
- [ ] Network connectivity works
- [ ] Update hostname to "QalarcAI" if needed:
  ```bash
  sudo hostnamectl set-hostname QalarcAI
  ```
- [ ] BIOS memory allocation is set correctly (96GB for iGPU)
- [ ] Run `nixos-rebuild switch` to apply any pending changes
