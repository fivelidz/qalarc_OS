# Troubleshooting Guide

**Common issues and how to fix them - written for beginners with step-by-step solutions.**

If something goes wrong, don't panic! This guide will help you solve most common problems.

---

## Table of Contents

- [Emergency Recovery](#emergency-recovery) 🚨 Start here if system won't boot!
- [Ollama Issues](#ollama-issues)
- [Performance Problems](#performance-problems)
- [Network Issues](#network-issues)
- [System Updates](#system-updates)
- [Snapshots & Rollback](#snapshots--rollback)
- [Storage Issues](#storage-issues)
- [Display & Graphics](#display--graphics)
- [Audio Problems](#audio-problems)
- [Getting More Help](#getting-more-help)

---

## Emergency Recovery

### System Won't Boot

**Symptoms:** Black screen, stuck at logo, or error messages during boot

**Solution 1: Boot from Snapshot**

1. **Restart your computer**
2. **Watch for GRUB menu** (appears for 5 seconds)
   - If you miss it, restart again and press ESC repeatedly
3. **Select "NixOS - Snapshots"** (use arrow keys)
4. **Choose a snapshot** from before the problem started
5. **Press Enter** to boot

[SCREENSHOT: GRUB menu with snapshots option highlighted]

**Solution 2: Boot from USB Installer**

If snapshots don't work:

1. **Insert Qalarc USB installer**
2. **Restart and boot from USB** (usually F12 or F2 during boot)
3. **Select "Boot existing OS"** option
4. **OR** mount your system and use `nixos-enter` to repair

**Solution 3: Safe Mode / Previous Generation**

1. **At GRUB menu**, select **"NixOS - All Generations"**
2. **Choose previous generation** (earlier version of your system)
3. **Boot and test**

---

### System Freezes or Crashes

**Symptoms:** Computer stops responding, mouse doesn't move

**Immediate actions:**

**Try 1: Magic SysRq Keys** (Emergency keyboard commands)
```
Alt + SysRq + R    # Take keyboard control
Alt + SysRq + E    # Terminate all processes
Alt + SysRq + I    # Kill all processes  
Alt + SysRq + S    # Sync disks
Alt + SysRq + U    # Unmount filesystems
Alt + SysRq + B    # Reboot
```

**Mnemonic: "REISUB" (Raising Elephants Is So Utterly Boring)**

Press each key combination slowly, wait 1-2 seconds between each.

**Try 2: Hard Reset**
- Hold power button for 10 seconds
- Wait 5 seconds
- Power on normally

**After recovery:**
```bash
# Check system logs to find cause
sudo journalctl -b -1 -p err  # Errors from last boot
```

---

## Ollama Issues

### "Ollama isn't running"

**Symptom:** Error message "Cannot connect to Ollama" or "Service not found"

**Solution:**

**1. Check if Ollama is running:**
```bash
sudo systemctl status ollama
```

**2. Start Ollama:**
```bash
sudo systemctl start ollama
```

**3. Enable Ollama to start automatically:**
```bash
sudo systemctl enable ollama
```

**4. Verify it's working:**
```bash
ollama list
```

**If still not working:**
```bash
# Check logs for errors
sudo journalctl -u ollama -n 50

# Restart the service
sudo systemctl restart ollama

# Check if port is already in use
sudo netstat -tlnp | grep 11434
```

---

### "Model is too slow"

**Symptom:** AI responses take forever or system lags

**Solutions:**

**1. Switch to a smaller model:**
```bash
# Instead of 70B model, use 7B
ollama run mistral:7b
```

**2. Close unnecessary applications:**
```bash
# Check what's using resources
btop
# Press 'q' to quit when done
```

**3. Check available RAM:**
```bash
free -h
```

If "available" is less than 10GB, you need to close apps or use smaller models.

**4. One AI session at a time:**
- Close other OpenCode/Claude sessions
- Exit browser tabs you're not using

**5. Let first response complete:**
- First response is always slower (model loading)
- Subsequent responses will be faster

**Model size recommendations:**

| Your RAM | Recommended Max Model |
|----------|----------------------|
| 32GB | 7B models |
| 64GB | 32B models |
| 128GB | 70B models |
| 256GB | 100B+ models |

---

### "Out of memory" Error

**Symptom:** AI crashes with "OOM" error, system freezes, or "Out of memory" message

**Immediate fix:**
```bash
# Kill the AI process
pkill ollama

# Restart with smaller model
ollama run mistral:7b
```

**Long-term solutions:**

**1. Check memory usage:**
```bash
free -h
htop  # Press F10 to quit
```

**2. Use smaller models:**
```bash
# List models and their sizes
ollama list

# Remove large models you don't use
ollama rm llama3.3:70b

# Use smaller alternatives
ollama pull qwen2.5-coder:7b  # Instead of :32b
```

**3. Configure swap (advanced):**
```bash
# Check swap status
swapon --show

# If no swap, you may need to add it
# (Ask for help with this)
```

---

### Models Download Very Slowly

**Symptom:** `ollama pull` takes hours or shows slow speed

**Solutions:**

**1. Check internet speed:**
```bash
# Install speedtest if needed
nix-shell -p speedtest-cli

# Run speed test
speedtest-cli
```

**2. Use wired connection:**
- WiFi is slower than ethernet
- Plug in cable if possible

**3. Pause and resume:**
- Ollama automatically resumes interrupted downloads
- Press `Ctrl+C` to pause
- Run same `ollama pull` command to resume

**4. Download during off-peak hours:**
- Late night or early morning
- Less internet congestion

**5. Try a different mirror (advanced):**
```bash
# Check Ollama status
sudo systemctl status ollama

# Edit Ollama config (if needed)
sudo systemctl edit ollama
```

**Estimated download times:**

| Model Size | Speed | Time |
|------------|-------|------|
| 4GB | 10 Mbps | ~60 minutes |
| 4GB | 100 Mbps | ~6 minutes |
| 20GB | 10 Mbps | ~5 hours |
| 20GB | 100 Mbps | ~30 minutes |
| 40GB | 10 Mbps | ~10 hours |
| 40GB | 100 Mbps | ~60 minutes |

---

## Performance Problems

### System Feels Sluggish

**Check what's using resources:**

```bash
btop  # Best system monitor
# Look for:
# - CPU usage (should be < 80% idle)
# - RAM usage (should have some "available")
# - Disk usage
```

[SCREENSHOT: btop showing system resources]

**Common causes and fixes:**

**1. Too many apps running:**
```bash
# Close apps you're not using
# Check system monitor (btop)
# Kill specific process:
pkill firefox  # Example
```

**2. AI model too large:**
- Switch to smaller model (see "Model is too slow" above)

**3. Disk full:**
```bash
# Check disk space
df -h

# Clean up if needed
ollama list  # Remove unused models
sudo nix-collect-garbage  # Clean old system versions
```

**4. Background processes:**
```bash
# See what's running
ps aux | grep -v grep

# Common culprits:
# - Multiple browser processes
# - Electron apps (VS Code, Discord, etc.)
# - Large downloads
```

---

### High CPU Usage

**Check what's using CPU:**

```bash
top
# Press 'Shift+P' to sort by CPU
# Press 'q' to quit

# Or use btop (prettier)
btop
```

**Common causes:**

**1. Ollama model running:**
- Normal! AI uses lots of CPU
- Exit AI when not needed: `Ctrl+D` or `/bye`

**2. System update in background:**
```bash
# Check if update is running
ps aux | grep nix-daemon
```
Wait for it to complete.

**3. Indexing (first boot):**
- System indexes files on first boot
- Wait 10-15 minutes, will slow down

**4. Runaway process:**
```bash
# Find and kill it
top
# Note the PID (Process ID)
kill <PID>
```

---

## Network Issues

### Can't Connect to WiFi

**Check WiFi is enabled:**

```bash
# Check WiFi status
nmcli radio wifi

# Turn on WiFi if off
nmcli radio wifi on
```

**Scan for networks:**

```bash
# List available networks
nmcli device wifi list

# Connect to network
nmcli device wifi connect "YourNetworkName" password "YourPassword"
```

**If network doesn't appear:**

1. **Check hardware switch** (some laptops have physical WiFi toggle)
2. **Restart network manager:**
```bash
sudo systemctl restart NetworkManager
```
3. **Check if driver is loaded:**
```bash
lspci | grep -i network  # Shows network hardware
dmesg | grep -i wifi     # Shows WiFi driver messages
```

---

### Connected But No Internet

**Test connectivity:**

```bash
# Ping Google DNS
ping 8.8.8.8

# Ping by name
ping google.com
```

**If numbers work but names don't:**

DNS issue. Fix:
```bash
# Temporarily use Google DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Permanent fix: Edit connection in System Settings
# System Settings → Connections → Your WiFi → IPv4 Settings
# Set DNS to: 8.8.8.8, 8.8.4.4
```

**If nothing works:**

1. **Check router** - restart it
2. **Check if other devices work** - might be internet provider issue
3. **Try wired connection** - to isolate WiFi issue

---

### Slow Internet

**Test speed:**

```bash
nix-shell -p speedtest-cli
speedtest-cli
```

**If slower than expected:**

1. **WiFi signal weak?** Move closer to router
2. **Interference?** Try different WiFi channel on router
3. **Others using bandwidth?** Check router admin page
4. **Switch to 5GHz WiFi** if available (faster but shorter range)

**Check what's using bandwidth:**

```bash
# Install nethogs
nix-shell -p nethogs

# Monitor bandwidth usage
sudo nethogs

# Press 'q' to quit
```

---

## System Updates

### "How do I update the system?"

**Easy method (recommended for beginners):**

**1. GUI Update (KDE Discover):**
- Open **Discover** (app store)
- Click **Updates** tab at bottom
- Click **Update All**
- Wait for completion

**2. Command line update:**

```bash
# Navigate to qalarc_OS repo
cd ~/qalarc_OS

# Update flake inputs (get latest package versions)
nix flake update

# Rebuild system with updates
sudo nixos-rebuild switch --flake .#gmktec-01

# System will automatically create a snapshot before updating!
```

**Update process takes:** 10-30 minutes depending on changes

---

### Update Failed or System Broken After Update

**Don't panic! You have snapshots.**

**Solution 1: Rollback to previous generation:**

```bash
# See available generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous
sudo nixos-rebuild switch --rollback

# Reboot
sudo reboot
```

**Solution 2: Boot from snapshot (see [Emergency Recovery](#emergency-recovery))**

**Solution 3: Boot previous generation from GRUB:**
1. Restart
2. GRUB menu → "NixOS - All Generations"
3. Select previous generation
4. Boot and test

---

### "How do I rollback with snapshots?"

**Three methods to rollback:**

### Method 1: Command Line Rollback

```bash
# 1. List all snapshots
snapper list

# Output example:
#  # | Type   | Date                | Description
# ---+--------+---------------------+-------------
#  0 | single | 2026-01-01 10:00:00 | current
#  1 | pre    | 2026-01-08 15:30:00 | before update
#  2 | post   | 2026-01-08 15:45:00 | after update

# 2. Choose snapshot number (before the problem)
# Example: rollback to snapshot 1
sudo snapper rollback 1

# 3. Reboot to apply
sudo reboot
```

---

### Method 2: Boot from GRUB Menu

1. **Restart computer**
2. **At GRUB menu**, select **"NixOS - Snapshots"**
3. **Use arrow keys** to choose snapshot
4. **Press Enter** to boot into that snapshot
5. **If it works**, make it permanent:
   ```bash
   sudo snapper rollback <number>
   ```

---

### Method 3: Compare and Restore Files

**If you only want to restore specific files:**

```bash
# Mount a snapshot to browse its contents
sudo mount -o subvol=.snapshots/1/snapshot /dev/nvme0n1p2 /mnt

# Copy files you need
sudo cp /mnt/path/to/file ~

# Unmount
sudo umount /mnt
```

---

### Create Manual Snapshot

**Before making risky changes:**

```bash
# Quick snapshot
sudo snapper -c root create --description "Before trying something risky"

# Or use shortcut
qalarc-snapshot "Before editing important config"

# Verify it was created
snapper list
```

---

## Storage Issues

### "Disk is full"

**Check disk usage:**

```bash
# See disk space
df -h

# See what's using space
du -sh /* 2>/dev/null | sort -h
```

**Free up space:**

**1. Remove unused AI models:**
```bash
# List models and sizes
ollama list

# Remove models you don't use
ollama rm model-name
```

**2. Clean old system generations:**
```bash
# Remove old NixOS versions (keeps last 5)
sudo nix-collect-garbage --delete-older-than 30d

# More aggressive (keeps last 3)
sudo nix-collect-garbage --delete-older-than 7d
```

**3. Clean old snapshots:**
```bash
# List snapshots
snapper list

# Delete specific snapshot
sudo snapper delete 5

# Delete range of snapshots
sudo snapper delete 10-20

# Clean old snapshots automatically (keeps important ones)
sudo snapper cleanup timeline
```

**4. Empty trash:**
```bash
rm -rf ~/.local/share/Trash/*
```

**5. Clear browser cache:**
- Firefox: Settings → Privacy & Security → Clear Data
- Brave: Settings → Additional Settings → Privacy → Clear browsing data

**6. Check downloads folder:**
```bash
du -sh ~/Downloads
# Delete old downloads you don't need
```

---

### "No space left on device"

**Emergency fix:**

```bash
# Find biggest files
sudo find / -type f -size +1G 2>/dev/null

# Find biggest directories  
du -h / 2>/dev/null | sort -h | tail -20

# Quick wins:
# - Remove old AI models
ollama list
ollama rm <unused-model>

# - Clean nix store
sudo nix-collect-garbage -d

# - Remove old snapshots
snapper list
sudo snapper delete <old-snapshot-number>
```

---

## Display & Graphics

### Display Not Working / Black Screen

**Try different TTY:**
```
Ctrl + Alt + F2  # Switch to text console
# Login with username and password
# Try to start desktop:
systemctl restart display-manager
```

**Check logs:**
```bash
sudo journalctl -u display-manager -n 50
dmesg | grep -i "error"
```

---

### Resolution Wrong / Display Looks Weird

**Change resolution:**

1. **System Settings → Display Configuration**
2. **Select your monitor**
3. **Choose resolution from dropdown**
4. **Apply**

**Command line method:**
```bash
# List available modes
xrandr

# Set resolution
xrandr --output <display-name> --mode 1920x1080

# Example:
xrandr --output eDP-1 --mode 1920x1080
```

---

### GPU Not Working / Poor 3D Performance

**Check GPU status:**

```bash
# AMD GPU info
rocm-smi

# Check if GPU is detected
lspci | grep -i vga
```

**Check GPU is being used:**
```bash
# Install GPU monitoring
nix-shell -p nvtop

# Run monitor
nvtop
```

**If GPU not showing:**
1. Check BIOS - make sure UMA is configured (96GB)
2. Run UMA check script:
```bash
~/qalarc_OS/scripts/check-uma-allocation.sh
```

---

## Audio Problems

### No Sound

**Check if muted:**

1. **Click speaker icon** in system tray
2. **Unmute** if needed
3. **Raise volume**

**Command line:**
```bash
# List audio devices
aplay -l

# Set volume
amixer set Master 50%

# Unmute
amixer set Master unmute
```

**Check PulseAudio:**
```bash
# Restart audio
systemctl --user restart pulseaudio

# Or
pulseaudio -k  # Kills it
pulseaudio --start  # Starts it
```

---

### Wrong Audio Device

**Switch audio output:**

1. **System Settings → Audio**
2. **Select correct output device**

**Command line:**
```bash
# List devices
pacmd list-sinks

# Set default
pacmd set-default-sink <device-number>
```

---

## Common Error Messages

### "Permission denied"

**Cause:** You don't have permission to access a file/command

**Fix:**
- Add `sudo` before command for system operations
- Example: `sudo nixos-rebuild switch`

**If sudo doesn't work:**
```bash
# Check if you're in wheel group
groups

# Add yourself to wheel (if not there)
sudo usermod -aG wheel $USER

# Logout and login again
```

---

### "Command not found"

**Cause:** Command isn't installed or not in PATH

**Fix:**

1. **Check if command exists:**
```bash
which command-name
```

2. **Install temporarily:**
```bash
nix-shell -p package-name
```

3. **Install permanently** - add to NixOS config:
Edit `~/qalarc_OS/hosts/gmktec-01/configuration.nix`

---

### "Failed to start <service>"

**Check service status:**
```bash
sudo systemctl status <service-name>

# Example:
sudo systemctl status ollama
```

**View detailed logs:**
```bash
sudo journalctl -u <service-name> -n 50

# Example:
sudo journalctl -u ollama -n 50
```

**Restart service:**
```bash
sudo systemctl restart <service-name>
```

---

## Getting More Help

### Built-in Help System

```bash
# Interactive help menu
qalarc-explain

# Man pages
man <command>

# Quick examples
tldr <command>  # Install: nix-shell -p tldr
```

---

### System Information

**Gather info to share when asking for help:**

```bash
# System info
uname -a

# NixOS version
nixos-version

# Hardware info
lshw -short

# All system state
cat /var/lib/qalarc/system-state.json | jq
```

---

### Check Logs

**System logs:**
```bash
# All errors from current boot
sudo journalctl -b -p err

# Last 100 lines of system log
sudo journalctl -n 100

# Follow log in real-time
sudo journalctl -f

# Specific service logs
sudo journalctl -u <service-name>
```

**Application logs:**
```bash
# Ollama logs
sudo journalctl -u ollama

# Display manager (login) logs
sudo journalctl -u display-manager

# Kernel messages
dmesg
```

---

### Community Support

**Before asking for help, gather:**
1. What you were trying to do
2. What happened instead
3. Any error messages (exact text)
4. System info (see above)

**Where to get help:**
- **Qalarc forums**: https://qalarc.com/community
- **Email support**: team@qalarc.com
- **NixOS community**: https://discourse.nixos.org/
- **Matrix chat**: #qalarc-os:matrix.org

---

### Reporting Bugs

**Good bug report includes:**

1. **Description**: What went wrong?
2. **Steps to reproduce**: How to trigger the bug?
3. **Expected behavior**: What should happen?
4. **Actual behavior**: What actually happened?
5. **System info**: Run `nixos-version` and `uname -a`
6. **Logs**: Relevant error messages

**Example bug report:**

```
Title: Ollama fails to start after update

Description:
After running system update on 2026-01-08, Ollama service 
won't start. Getting error "failed to bind to port".

Steps to reproduce:
1. Run: sudo nixos-rebuild switch --flake .#gmktec-01
2. Reboot
3. Try: ollama list
4. Error: "cannot connect to ollama"

Expected: Ollama should start automatically
Actual: Service fails with port binding error

System info:
- NixOS 25.05
- Kernel: 6.16.9
- Output of journalctl -u ollama:
  [paste error here]
```

---

## Emergency Contact Information

### Last Resort: Reset to Factory

**⚠️ WARNING: This will erase all your data!**

**Only do this if:**
- System is completely broken
- Snapshots don't work
- You have backups of important files

**Procedure:**
1. Boot from USB installer
2. Re-partition disks
3. Re-run installation
4. See [QUICK-START.md](../QUICK-START.md)

**Before doing this**, try:
- Booting from USB and using `nixos-enter` to repair
- Asking for help in community forums
- Contacting support@qalarc.com

---

## Quick Troubleshooting Checklist

**When something goes wrong:**

- [ ] Did I restart yet? (Fixes 50% of problems!)
- [ ] Is there enough disk space? (`df -h`)
- [ ] Is there enough RAM? (`free -h`)
- [ ] Are there error messages in logs? (`journalctl -b -p err`)
- [ ] Did this work before? What changed?
- [ ] Can I rollback/boot from snapshot?
- [ ] Did I try the solution in this guide?
- [ ] Have I asked for help?

**Remember:** It's okay to ask for help! Everyone struggles sometimes.

---

## Related Guides

- [GETTING_STARTED.md](./GETTING_STARTED.md) - Basic usage
- [AI_CODING_TUTORIAL.md](./AI_CODING_TUTORIAL.md) - AI tools
- [OLLAMA_MODELS_GUIDE.md](./OLLAMA_MODELS_GUIDE.md) - Managing models
- [KEYBOARD_SHORTCUTS.md](./KEYBOARD_SHORTCUTS.md) - Work faster

---

**Don't panic! Most problems have simple solutions.** 🔧

*If all else fails, remember: Your snapshots have your back!*

*Last updated: January 2026*
