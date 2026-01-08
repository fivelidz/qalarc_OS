# Portable Boot - Development TODO

## Current Sprint

### Must Have (MVP)
- [x] Basic NixOS module structure
- [x] CLI creation script (`qalarc-create-portable`)
- [x] Sync script (`qalarc-sync-portable`)
- [x] Status script (`qalarc-portable-status`)
- [x] GUI wrapper (`qalarc-portable-gui`)
- [x] User documentation (PORTABLE_BOOT_GUIDE.md)
- [x] Design documentation (ARCHITECTURE.md)
- [ ] Test on actual hardware
- [ ] Initrd hook for copytoram (needs testing)

### Should Have
- [ ] Progress bar during squashfs creation (improve current)
- [ ] Size estimation before starting
- [ ] Verify squashfs integrity after creation
- [ ] UEFI Secure Boot support (research needed)

### Nice to Have
- [ ] VM-based automated tests
- [ ] Incremental USB updates (diff-based)
- [ ] Multiple profiles (minimal, full, AI)

---

## Known Issues

### High Priority
1. **Initrd hook untested** - The copytoram boot process needs real hardware testing
2. **GRUB install may fail on UEFI-only systems** - Currently ignores error

### Medium Priority
1. **Large AI models** - Need better handling of 50GB+ model directories
2. **Compression time** - Level 15 zstd is slow; consider level 10 default

### Low Priority
1. **GUI toolkit detection** - Falls back to zenity but kdialog preferred
2. **Progress reporting** - Could be more granular

---

## Testing Checklist

### Before Release
- [ ] Create USB on NixOS (source system)
- [ ] Boot on Intel UEFI system
- [ ] Boot on AMD UEFI system
- [ ] Boot on Legacy BIOS system
- [ ] Test persistence sync
- [ ] Test with AI models included
- [ ] Test with user data included
- [ ] Test USB removal after boot
- [ ] Test on 8GB RAM system (minimum)
- [ ] Test on 16GB RAM system
- [ ] Test on 32GB+ RAM system with AI

### Hardware Tested
| System | CPU | RAM | BIOS Type | Result |
|--------|-----|-----|-----------|--------|
| TBD | | | | |

---

## Future Ideas

### Phase 2 - User Experience
- KDE System Settings integration
- Drag-drop folder selection
- Real-time space calculator
- One-click creation wizard
- Desktop notification on boot

### Phase 3 - Advanced
- Network boot (PXE) support
- Encrypted squashfs
- Fleet management
- Remote wipe capability
- Cloud sync for persistence

### Phase 4 - Enterprise
- Inventory tracking
- Usage analytics (opt-in)
- Custom branding support
- Multi-boot (version A/B)

---

## Notes

### Useful Commands
```bash
# Test squashfs creation
sudo mksquashfs /tmp/test /tmp/test.squashfs -comp zstd

# Check squashfs contents
unsquashfs -l /path/to/image.squashfs | head -50

# Test overlayfs manually
mount -t overlay overlay -o lowerdir=/lower,upperdir=/upper,workdir=/work /merged

# Check initrd contents
lsinitrd /boot/initrd.img | less
```

### Reference Links
- [NixOS Installation Guide](https://nixos.org/manual/nixos/stable/#sec-installation)
- [squashfs-tools](https://github.com/plougher/squashfs-tools)
- [overlayfs documentation](https://www.kernel.org/doc/Documentation/filesystems/overlayfs.txt)
- [systemd-boot](https://www.freedesktop.org/wiki/Software/systemd/systemd-boot/)

---

## Change Log

### 2026-01-08
- Initial module structure created
- CLI scripts implemented
- GUI wrapper added
- Documentation written
- Design documents created
