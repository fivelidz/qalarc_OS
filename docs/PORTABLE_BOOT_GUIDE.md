# qalarc_OS Portable Boot Guide

## What Is This? (ELI5)

Imagine putting your entire computer - operating system, apps, AI tools, everything - onto a USB stick. Then you can plug that USB into ANY computer, and it becomes YOUR computer with all your stuff. The magic part? Once it starts up, the whole system runs from the computer's RAM (memory), so it's super fast and you can even unplug the USB after it boots!

**Think of it like:**
- A portable brain for any computer
- Your personal AI workstation in your pocket
- A rescue system that works anywhere

---

## Hardware Requirements

### Minimum (Base System Only)
| Component | Requirement |
|-----------|-------------|
| RAM | 8 GB |
| USB Drive | 16 GB, USB 3.0+ |
| Boot | UEFI or Legacy BIOS |

### Recommended (Comfortable Use)
| Component | Requirement |
|-----------|-------------|
| RAM | 16 GB |
| USB Drive | 64 GB, USB 3.0+ |
| Boot | UEFI preferred |

### With AI Models
| Component | Requirement |
|-----------|-------------|
| RAM | 32-64 GB |
| USB Drive | 128-500 GB SSD |
| Boot | UEFI preferred |

### USB Drive Recommendations
- **Budget**: SanDisk Ultra Flair 64GB (~$10)
- **Better**: Samsung BAR Plus 128GB (~$20)
- **Best**: Samsung T7 Portable SSD 500GB (~$60)

> **Tip**: External SSDs are MUCH faster than USB flash drives for both creating and booting.

---

## Creating a Portable USB

### Method 1: GUI (Recommended)

1. Open **System Settings** → **qalarc_OS** → **Portable Boot**
2. Click **Create Portable USB**
3. Select your USB drive from the list
4. Choose what to include:
   - ☑ Base System (required)
   - ☐ AI Models (adds 10-50GB)
   - ☐ User Data (adds your files)
   - ☑ Persistence (save changes)
5. Click **Create**
6. Wait 10-30 minutes depending on size
7. Done! Safely eject the USB

### Method 2: Command Line

```bash
# Run the interactive wizard
sudo qalarc-create-portable
```

Follow the prompts:
```
╔═══════════════════════════════════════════════════════════════╗
║      qalarc_OS Portable Boot USB Creator                      ║
╚═══════════════════════════════════════════════════════════════╝

Available storage devices:
NAME   SIZE MODEL                    TRAN
sda    500G Samsung SSD 870          sata
sdb     64G SanDisk Ultra            usb

Enter target device (e.g., sdb): sdb

WARNING: All data on /dev/sdb will be DESTROYED!
Type 'YES' to continue: YES

Include AI models? (no/yes) [no]: no
Include user data from /home? (no/yes) [no]: no
Enable persistence partition? (yes/no) [yes]: yes

Calculating required space...
  Base system: ~5GB
  Total: ~5GB (compressed)

Device capacity: 64GB
Note: Target computer will need at least 9GB of RAM

Press ENTER to begin creation...
```

---

## Booting on Different Computers

### Step 1: Access Boot Menu

When the computer starts, press the boot menu key (before Windows/Linux loads):

| Manufacturer | Key |
|--------------|-----|
| Dell | F12 |
| HP | F9 or Esc |
| Lenovo | F12 or Fn+F12 |
| ASUS | F8 or Esc |
| Acer | F12 |
| MSI | F11 |
| Intel NUC | F10 |
| Generic | Esc, F2, F10, F11, or F12 |

### Step 2: Select USB Drive

Look for entries like:
- "USB: SanDisk"
- "UEFI: USB Drive"
- "Generic USB Device"

Select your qalarc USB and press Enter.

### Step 3: Wait for Loading

You'll see:
```
=== qalarc_OS Portable Boot: Loading to RAM ===
Copying system image... [=========>         ] 45%
```

**This takes 2-5 minutes** depending on USB speed and image size. The system is copying itself into RAM.

### Step 4: Done!

Once the desktop appears, the USB can be safely removed. Everything is running from RAM now.

---

## BIOS/UEFI Settings (If Boot Menu Doesn't Work)

### Enable USB Boot

1. Enter BIOS/UEFI Setup (usually F2, Del, or F10 at startup)
2. Find **Boot** or **Boot Order** section
3. Enable:
   - "USB Boot" or "Boot from USB"
   - "Legacy USB Support" (for older systems)
4. Move USB to top of boot order
5. Save and Exit (usually F10)

### Disable Secure Boot (If Needed)

Some computers require disabling Secure Boot:

1. In BIOS/UEFI, find **Security** or **Boot** section
2. Set **Secure Boot** to **Disabled**
3. Save and Exit

> **Note**: You can re-enable Secure Boot after booting qalarc_OS

### Enable Legacy/CSM Mode (For Very Old Computers)

If UEFI boot fails:

1. Find **Boot Mode** or **CSM** settings
2. Enable **Legacy** or **CSM** support
3. Save and reboot

---

## Saving Your Changes (Persistence)

When running from portable boot, all changes are in RAM and will be lost on shutdown. To save changes:

### Check Persistence Status
```bash
qalarc-portable-status
```

### Sync Changes to USB
```bash
sudo qalarc-sync-portable
```

This opens a menu:
```
What would you like to sync?
  1) Home directories only
  2) System configuration only
  3) Both home and config
  4) Custom paths

Choice [3]: 
```

Select an option and your changes will be saved to the persistence partition.

---

## Troubleshooting

### Problem: USB doesn't show up in boot menu

**Solutions:**
1. Try a different USB port (use USB 2.0 port if USB 3.0 fails)
2. Enable "USB Boot" in BIOS
3. Try Legacy/CSM mode
4. Remake the USB on a different drive

### Problem: Boot hangs at "Loading to RAM"

**Causes:**
- Slow USB drive
- Corrupted squashfs image
- Not enough RAM

**Solutions:**
1. Wait longer (can take 5+ minutes on slow USBs)
2. Use a faster USB drive or SSD
3. Recreate the USB with `--verify` option
4. Check target computer has enough RAM

### Problem: "Not enough memory" error

**Solutions:**
1. Use a computer with more RAM
2. Recreate USB without AI models
3. Create a minimal image:
   ```bash
   sudo qalarc-create-portable --minimal
   ```

### Problem: Graphics issues / black screen

**Solutions:**
1. At boot menu, select "Safe Mode" instead
2. Add `nomodeset` to kernel parameters
3. Try on a computer with compatible GPU

### Problem: WiFi not working

**Solutions:**
1. Use ethernet instead
2. The portable image may not have your WiFi drivers
3. Recreate with `--include-firmware` option

### Problem: Changes not saving

**Solutions:**
1. Make sure you created with persistence enabled
2. Run `qalarc-sync-portable` before shutdown
3. Check persistence partition:
   ```bash
   lsblk -f | grep QALARC_DATA
   ```

---

## Advanced Usage

### Recreate USB Keeping Persistence

```bash
# Update system image but keep user data
sudo qalarc-create-portable --preserve-data
```

### Include Specific Folders

```bash
sudo qalarc-create-portable --include /path/to/project --include /path/to/other
```

### Create Minimal Rescue Image

```bash
# ~2GB image, boots fast, basic tools
sudo qalarc-create-portable --minimal --no-persistence
```

### Boot Options

At the boot menu, you can edit boot options:
- `copytoram` - Load to RAM (default)
- `nomodeset` - Safe graphics mode
- `debug` - Verbose boot logging
- `single` - Single user mode

---

## Tips for Best Experience

1. **Use an SSD** - External SSDs boot 3-5x faster than USB flash drives

2. **Close apps before sync** - Ensures clean state saved to persistence

3. **Keep a backup** - Important data should also exist elsewhere

4. **Update periodically** - Recreate the USB when qalarc_OS updates

5. **Label your USB** - Write the creation date and what's included

6. **Test before relying on it** - Boot on a few computers to ensure it works

---

## How It Works (Technical)

1. **Boot partition** contains a compressed squashfs image (~4GB for full system)

2. **At boot**, the initrd copies this image entirely into RAM

3. **overlayfs** mounts the squashfs as read-only lower layer

4. **tmpfs** provides a writable upper layer in RAM

5. **All writes** go to RAM (tmpfs), reads come from squashfs or overlay

6. **Persistence partition** (optional) stores data that survives reboots

7. **Sync command** copies RAM changes to persistence partition

---

## Getting Help

- Check status: `qalarc-portable-status`
- This guide: `/usr/share/doc/qalarc-portable/PORTABLE_BOOT_GUIDE.md`
- qalarc forums: https://qalarc.com/community
- Issues: https://github.com/qalarc/qalarc_OS/issues
