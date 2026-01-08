# Design Decisions Log

This document tracks key architectural and design decisions for the portable boot feature.

---

## Decision 001: Filesystem Choice for System Image

**Date**: 2026-01-08  
**Status**: Decided

### Context
Need a compressed filesystem format for the portable system image that balances:
- Compression ratio
- Read performance
- Memory efficiency
- Linux kernel support

### Options Considered
1. **squashfs** - Standard Linux compressed read-only FS
2. **erofs** - Enhanced Read-Only FS, newer, potentially faster
3. **btrfs with compression** - Read-write but can be made RO

### Decision
**squashfs with zstd compression**

### Rationale
- Universal kernel support (no extra modules needed)
- Excellent compression with zstd (level 15-19)
- Well-tested, stable, mature
- NixOS installer already uses squashfs
- erofs is faster but less tested for this use case

---

## Decision 002: Overlay Filesystem for Writes

**Date**: 2026-01-08  
**Status**: Decided

### Context
System boots from read-only squashfs but needs to appear writable.

### Options Considered
1. **overlayfs** - Standard union mount in kernel
2. **aufs** - Older union FS, not in mainline
3. **Copy-on-write in userspace** - FUSE-based solution

### Decision
**overlayfs with tmpfs upper layer**

### Rationale
- In mainline kernel, no patches needed
- High performance (kernel-level)
- Simple to set up in initrd
- tmpfs upper layer provides RAM-backed writes
- Well-documented and widely used (Docker, etc.)

---

## Decision 003: Bootloader Strategy

**Date**: 2026-01-08  
**Status**: Decided

### Context
Need to boot on any computer regardless of BIOS/UEFI configuration.

### Options Considered
1. **systemd-boot only** - Modern, simple, UEFI only
2. **GRUB only** - Supports both but complex
3. **Hybrid approach** - Both bootloaders

### Decision
**Hybrid: systemd-boot for UEFI + GRUB for Legacy BIOS**

### Rationale
- Maximum compatibility across hardware
- systemd-boot is cleaner for UEFI
- GRUB handles legacy BIOS well
- Both can coexist without conflict
- Users don't need to know/choose

---

## Decision 004: Persistence Implementation

**Date**: 2026-01-08  
**Status**: Decided

### Context
Allow users to save data that survives reboots while still running from RAM.

### Options Considered
1. **No persistence** - Pure RAM, all changes lost
2. **Automatic overlay merge** - Changes auto-saved
3. **Manual sync** - User chooses when to save

### Decision
**Manual sync with `qalarc-sync-portable` command**

### Rationale
- Explicit control over what gets saved
- No risk of corrupting persistence during unexpected shutdown
- User can choose to discard changes
- Faster boot (no merge on startup)
- Can still auto-mount persistence for manual file access

---

## Decision 005: User Interface for Creation

**Date**: 2026-01-08  
**Status**: In Progress

### Context
How should users create portable USBs?

### Options Considered
1. **CLI only** - Simple but intimidating
2. **GUI only** - Pretty but can't be scripted
3. **Both CLI and GUI** - Maximum flexibility

### Decision
**Both: CLI wizard + KDE GUI application**

### Rationale
- CLI for power users, scripting, automation
- GUI for casual users, discoverability
- GUI can call CLI tool internally
- Consistent behavior regardless of interface

---

## Decision 006: What to Include by Default

**Date**: 2026-01-08  
**Status**: Decided

### Context
What should be in the base portable image?

### Decision

**Default includes:**
- Full NixOS system closure (current generation)
- /etc configuration
- Essential services

**Optional (user chooses):**
- AI models (/var/lib/ollama)
- User home directories
- Development projects

**Excluded:**
- Nix store garbage (old generations)
- Cache files
- Temporary files
- Logs

### Rationale
- Keep base image small (~4GB compressed)
- AI models are huge (10-50GB) and not always needed
- User data is personal choice
- Let users customize for their use case

---

## Decision 007: Compression Algorithm

**Date**: 2026-01-08  
**Status**: Decided

### Context
Choose compression for squashfs image.

### Options Considered
| Algorithm | Ratio | Decompress Speed | CPU Usage |
|-----------|-------|------------------|-----------|
| gzip | Good | Fast | Low |
| lzo | OK | Very Fast | Low |
| xz | Excellent | Slow | High |
| zstd | Excellent | Fast | Medium |

### Decision
**zstd at level 15**

### Rationale
- Near xz compression ratios
- Much faster decompression than xz
- Good balance for boot time vs image size
- Level 15 gives good compression without extreme build time

---

## Future Decisions to Make

- [ ] Should we support Secure Boot?
- [ ] How to handle driver compatibility across hardware?
- [ ] Should persistence be encrypted by default?
- [ ] How to handle firmware blobs for various hardware?
- [ ] Strategy for incremental updates to portable USB
