# Qalarc OS Installation Issues Log

## Date: January 8, 2026

---

## Critical Issues Found

### 1. **CachyOS Kernel - No Binary Cache**
- **Error:** `Can not derive a closure of kernel modules because no modules were provided`
- **Cause:** Chaotic-Nyx binary cache not providing pre-built CachyOS kernel modules
- **Fix Applied:** Changed to `linuxPackages_latest` in all host configs
- **TODO:** Investigate why chaotic cache isn't working, or build cachyos locally

### 2. **Package Hash Mismatches (Placeholder Hashes)**
- **grub-btrfs:** Had outdated hash
  - Fixed: `sha256-a4d79OHAwoljzoACp437+pHjRkHvteq31HBNYU+z+uw=`
- **opencode:** Had placeholder `AAAA...` hash
  - Fixed: `sha256-Kcwd8deHug7BPDzmbdFqEfoArpXJb1JtBKuk+drdohM=`
- **claude-code:** Custom package had broken npmDepsHash
  - Fixed: Removed custom package, using nixpkgs version (2.0.76)
- **TODO:** Add hash verification script, remove all placeholder hashes

### 3. **nixos-rebuild Interruptions**
- SSH connection drops when services restart mid-rebuild
- Display manager (SDDM) restarts, causing black screen
- System becomes unresponsive, requiring reboot
- **TODO:** Consider using `nixos-rebuild boot` instead of `switch` for major changes

### 4. **USB Installer Issues**
- `/mnt/tmp` doesn't exist, causing `mktemp` to fail
- **Error:** `mktemp: failed to create directory via template '/mnt/tmp.XXXXXXXXXX': Permission denied`
- **TODO:** Add `mkdir -p /mnt/tmp && chmod 1777 /mnt/tmp` to installer script

### 5. **ISO Missing Full Repository**
- ISO only contains minimal flake at `/etc/qalarc_OS/`
- Need to clone full repo from GitHub during install
- **TODO:** Include full repo on ISO, or improve `qalarc-install` to handle this

---

## UI/UX Issues

### 1. **Installer Interface**
- No progress indicator during long builds
- No clear status messages
- Terminal-only, no GUI option
- **TODO:** Add progress bars, status updates, consider whiptail/dialog TUI

### 2. **Welcome Screen**
- Basic text-only banner
- Could be more visually appealing
- **TODO:** Add ASCII art, colors, better formatting

### 3. **Error Messages**
- Nix errors are cryptic and unhelpful for users
- No troubleshooting guidance shown
- **TODO:** Wrap common errors with user-friendly messages

---

## Configuration Issues

### 1. **Flake Target Confusion**
- Multiple targets: `gmktec-01`, `gmktec-01-single-drive`, `gmktec-01-minimal`
- Users don't know which to choose
- **TODO:** Auto-detect hardware and suggest correct target

### 2. **Git Tree Dirty Warning**
- Happens when local changes exist
- Confusing for users
- **TODO:** Either commit all changes or use `--impure` flag

### 3. **BIOS UMA Setting**
- Critical for AI performance (96GB)
- Not prominently mentioned
- **TODO:** Add pre-flight check that warns if UMA < 96GB

---

## Missing Features

### 1. **Post-Install Setup**
- No automatic first-boot wizard
- No model download prompts
- **TODO:** Create systemd service for first-boot setup

### 2. **Hardware Detection**
- No automatic GPU detection
- No RAM check for AI workloads
- **TODO:** Add hardware detection to installer

### 3. **Network Setup**
- WiFi setup is manual
- No Tailscale auto-configuration
- **TODO:** Add guided network setup

---

## Commands That Should Work After Install

```bash
# System info
qalarc-welcome
qalarc-system-info
qalarc-setup

# AI tools
ollama run qwen2.5-coder:7b
claude
opencode

# Desktop shortcuts
Meta+Return  → Ghostty terminal
Meta+A       → AI Quick launcher
Meta+Shift+S → Screenshot
```

---

## Files Modified This Session

1. `hosts/gmktec-01/configuration.nix` - kernel change
2. `hosts/gmktec-01-single-drive/configuration.nix` - kernel change
3. `hosts/mini-pc-low-end/configuration.nix` - kernel change
4. `packages/grub-btrfs/default.nix` - hash fix
5. `packages/opencode/default.nix` - hash fix
6. `packages/default.nix` - removed claude-code (using nixpkgs)

---

## Next Steps

1. [ ] Fix installer to create `/mnt/tmp`
2. [ ] Include full repo on ISO
3. [ ] Add progress indicators to install script
4. [ ] Improve error handling and messages
5. [ ] Add hardware detection
6. [ ] Test fresh install end-to-end
7. [ ] Document all qalarc-* commands
