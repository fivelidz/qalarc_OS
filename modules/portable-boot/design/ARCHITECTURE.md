# Portable Boot Architecture

## Overview

The portable boot feature allows users to create a USB/SSD that boots qalarc_OS entirely into RAM on any computer. Once loaded, the boot device can be removed.

## System Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    PORTABLE USB/SSD LAYOUT                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Partition 1: EFI (512MB, FAT32)                               │
│  ├── EFI/BOOT/BOOTX64.EFI    (systemd-boot for UEFI)          │
│  ├── loader/                                                    │
│  │   ├── loader.conf                                           │
│  │   └── entries/qalarc-portable.conf                          │
│  ├── qalarc-kernel.efi                                         │
│  └── qalarc-initrd.img                                         │
│                                                                 │
│  Partition 2: BOOT (Variable, ext4, LABEL=QALARC_BOOT)         │
│  ├── qalarc.squashfs         (compressed system image)         │
│  ├── grub/grub.cfg           (for legacy BIOS)                 │
│  ├── qalarc-kernel.efi       (copy for GRUB)                   │
│  └── qalarc-initrd.img       (copy for GRUB)                   │
│                                                                 │
│  Partition 3: DATA (Remaining, ext4, LABEL=QALARC_DATA)        │
│  ├── home/                   (persistent user data)            │
│  ├── var/                    (persistent system state)         │
│  └── etc/                    (persistent configuration)        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Boot Flow

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   BIOS/UEFI  │───▶│  Bootloader  │───▶│    Kernel    │
│  Select USB  │    │ GRUB/systemd │    │   + initrd   │
└──────────────┘    └──────────────┘    └──────┬───────┘
                                               │
                    ┌──────────────────────────▼───────┐
                    │         INITRD STAGE             │
                    │  1. Detect copytoram parameter   │
                    │  2. Find QALARC_BOOT partition   │
                    │  3. Mount boot partition         │
                    │  4. Copy squashfs to tmpfs       │
                    │  5. Mount squashfs (lower)       │
                    │  6. Create tmpfs overlay (upper) │
                    │  7. Mount overlayfs as root      │
                    │  8. Unmount boot partition       │
                    │  9. USB can now be removed       │
                    └──────────────────────────────────┘
                                               │
                    ┌──────────────────────────▼───────┐
                    │         RUNNING SYSTEM           │
                    │                                  │
                    │  ┌────────────────────────────┐  │
                    │  │        overlayfs           │  │
                    │  │  upperdir: tmpfs (RAM)     │  │
                    │  │  lowerdir: squashfs        │  │
                    │  └────────────────────────────┘  │
                    │                                  │
                    │  All writes go to tmpfs (RAM)   │
                    │  Reads from squashfs + overlay  │
                    └──────────────────────────────────┘
```

## Key Technologies

### squashfs
- Compressed read-only filesystem
- ~3:1 compression ratio with zstd
- Fast random read access
- Perfect for immutable system base

### overlayfs
- Union filesystem (merges multiple layers)
- Lower layer: squashfs (read-only)
- Upper layer: tmpfs (read-write, in RAM)
- Changes appear instant, stored in RAM

### copytoram
- Custom kernel parameter
- Triggers initrd script to load system to RAM
- Enables USB removal after boot

## Size Estimates

| Component | Compressed | In RAM | Notes |
|-----------|------------|--------|-------|
| Base system | ~3-4 GB | ~3-4 GB | NixOS closure |
| AI models (optional) | ~10-50 GB | ~10-50 GB | Ollama models |
| User data (optional) | Variable | Variable | /home contents |
| Overlay headroom | - | ~2-4 GB | For runtime writes |
| System overhead | - | ~2 GB | Kernel, services |

### RAM Requirements
- **Minimum**: 8 GB (base system only)
- **Recommended**: 16 GB (comfortable with apps)
- **With AI models**: 32-64 GB (depending on model sizes)

## Files in This Module

```
modules/portable-boot/
├── default.nix              # Main NixOS module
├── design/
│   ├── ARCHITECTURE.md      # This file
│   ├── FEATURES.md          # Feature roadmap
│   └── DECISIONS.md         # Design decisions log
├── docs/
│   └── PORTABLE_BOOT_GUIDE.md  # User documentation
├── scripts/
│   └── (embedded in default.nix as writeShellScriptBin)
└── tests/
    └── (future: VM-based tests)
```

## Integration Points

### With qalarc_OS Installer
- Option during install to create portable USB
- Can be done post-install from running system

### With Branding Module
- Uses qalarc wallpapers and theming
- Shows qalarc logo during boot

### With AI-ML Module
- Option to include Ollama models
- Warns about size implications
