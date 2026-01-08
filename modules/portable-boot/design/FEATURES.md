# Portable Boot Feature Roadmap

## Current Status: v0.1 (In Development)

---

## Phase 1: Core Functionality (Current)

### Completed
- [x] Basic NixOS module structure
- [x] `qalarc-create-portable` script (CLI wizard)
- [x] `qalarc-sync-portable` script (persistence sync)
- [x] `qalarc-portable-status` script (status check)
- [x] squashfs creation with zstd compression
- [x] Dual boot support (UEFI + Legacy BIOS)
- [x] overlayfs for RAM-based writes
- [x] Persistence partition support

### In Progress
- [ ] GUI wizard for creating portable USB
- [ ] Integration with KDE system settings
- [ ] Progress bar improvements
- [ ] Verification and integrity checks

### Not Started
- [ ] VM-based testing framework
- [ ] Automatic model detection and sizing

---

## Phase 2: User Experience (Next)

### GUI Creation Wizard
```
┌─────────────────────────────────────────────────────────┐
│  Create Portable qalarc_OS USB                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Select Target Device:                                  │
│  ┌───────────────────────────────────────────────────┐  │
│  │ ○ /dev/sdb - SanDisk Ultra 64GB                  │  │
│  │ ○ /dev/sdc - Samsung T7 1TB                      │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  What to Include:                                       │
│  ┌───────────────────────────────────────────────────┐  │
│  │ ☑ Base System (~4GB)                             │  │
│  │ ☐ AI Models (~25GB) - llama3, codellama          │  │
│  │ ☐ User Data (~8GB) - /home/user                  │  │
│  │ ☑ Persistence Partition                          │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  Space Required: 12GB / 64GB available                  │
│  RAM Needed: 16GB minimum                               │
│                                                         │
│  [Cancel]                              [Create USB]     │
└─────────────────────────────────────────────────────────┘
```

### Features
- [ ] KDE Plasma integration (System Settings module)
- [ ] Drag-and-drop folder selection for inclusion
- [ ] Real-time space calculation
- [ ] RAM requirement calculator
- [ ] One-click creation with progress dialog
- [ ] Desktop notification on completion

---

## Phase 3: Advanced Features

### Smart Model Selection
- [ ] List available Ollama models with sizes
- [ ] Allow selecting specific models to include
- [ ] Estimate RAM requirements based on selection
- [ ] Warn if models won't fit in typical RAM

### Profile System
- [ ] Save/load portable creation profiles
- [ ] "AI Workstation" profile (includes models)
- [ ] "Development" profile (includes dev tools/projects)
- [ ] "Presentation" profile (minimal, fast boot)
- [ ] "Rescue" profile (recovery tools)

### Differential Updates
- [ ] Update existing portable USB without full recreate
- [ ] Sync only changed Nix store paths
- [ ] Preserve user data during updates

---

## Phase 4: Enterprise Features

### Network Boot Integration
- [ ] PXE boot support (boot over network to RAM)
- [ ] Multicast deployment to many machines
- [ ] Central management of portable images

### Security Features
- [ ] Encrypted squashfs option
- [ ] Secure boot support
- [ ] TPM integration for decryption
- [ ] Attestation of boot chain

### Fleet Management
- [ ] Serial number tracking
- [ ] Usage analytics (opt-in)
- [ ] Remote wipe capability
- [ ] Inventory management

---

## Technical Debt / Improvements

### Code Quality
- [ ] Split large scripts into functions
- [ ] Add proper error handling throughout
- [ ] Implement logging to file
- [ ] Add --dry-run option to creation script

### Testing
- [ ] QEMU-based automated tests
- [ ] Test on various USB drives
- [ ] Test on different hardware (Intel, AMD, various BIOSes)
- [ ] Benchmark boot times and RAM usage

### Documentation
- [ ] Video tutorial for USB creation
- [ ] Troubleshooting flowchart
- [ ] Hardware compatibility list
- [ ] Performance tuning guide

---

## Ideas for Future Consideration

1. **Live customization tool** - Modify portable image without recreating
2. **Cloud sync** - Sync persistence to cloud storage
3. **Multi-boot** - Multiple qalarc versions on one USB
4. **Hardware profiles** - Auto-detect and optimize for specific hardware
5. **Kiosk mode** - Locked-down portable for specific use cases
6. **Companion app** - Mobile app to monitor/control portable instance
