# qalarc_OS Portable Boot Module

Create a USB drive that boots qalarc_OS on **any computer**, loading the entire system into RAM for maximum speed.

## Quick Start

### Enable the Module

In your NixOS configuration:

```nix
{
  imports = [ ./modules/portable-boot ];
  
  qalarc.portableBoot = {
    enable = true;
    
    # Optional: customize RAM usage
    copytoram.ramSize = "75%";  # or "16G"
    
    # Optional: persistence settings
    persistence = {
      enable = true;
      autoMount = true;
    };
  };
}
```

### Create a Portable USB

**GUI Method:**
- Open "qalarc Portable Creator" from the application menu
- Follow the wizard

**CLI Method:**
```bash
sudo qalarc-create-portable
```

### Available Commands

| Command | Description |
|---------|-------------|
| `qalarc-create-portable` | Create a new portable USB (interactive wizard) |
| `qalarc-sync-portable` | Save RAM changes to USB persistence partition |
| `qalarc-portable-status` | Check if running portable, show memory usage |
| `qalarc-portable-gui` | Launch GUI wizard |

## Directory Structure

```
modules/portable-boot/
├── default.nix           # Main NixOS module
├── options.nix           # Module options definition
├── README.md             # This file
├── design/
│   ├── ARCHITECTURE.md   # Technical architecture
│   ├── FEATURES.md       # Feature roadmap
│   └── DECISIONS.md      # Design decision log
├── docs/
│   └── PORTABLE_BOOT_GUIDE.md  # User guide
├── scripts/
│   ├── default.nix       # Script definitions
│   ├── create-portable.sh
│   ├── sync-portable.sh
│   ├── portable-status.sh
│   └── portable-gui.sh
└── tests/
    └── (future VM tests)
```

## How It Works

1. **Create**: Compresses your system into a squashfs image on USB
2. **Boot**: USB boots kernel which copies squashfs to RAM
3. **Run**: overlayfs makes the system writable (changes go to RAM)
4. **Remove**: USB can be unplugged - system runs entirely from RAM
5. **Sync**: Optionally save changes back to USB persistence partition

## Requirements

| Use Case | RAM | USB Size |
|----------|-----|----------|
| Base system | 8GB | 16GB |
| Comfortable use | 16GB | 64GB |
| With AI models | 32-64GB | 128GB+ |

## Configuration Options

```nix
qalarc.portableBoot = {
  enable = true;
  
  copytoram = {
    enable = true;     # Enable copytoram in initrd
    ramSize = "75%";   # tmpfs size for RAM root
  };
  
  persistence = {
    enable = true;      # Support persistence partition
    autoMount = true;   # Mount persistence at boot
    autoRestore = false; # Restore /home from persistence
    mountPoint = "/mnt/qalarc-persist";
  };
  
  defaults = {
    includeAIModels = false;  # Include ollama models
    includeUserData = false;  # Include /home
    compressionLevel = 15;    # zstd level (1-19)
  };
};
```

## Development

### Testing Changes

```bash
# Test in VM (WIP)
cd tests && ./run-vm-test.sh

# Build module documentation
nix-build -A nixosModules.portable-boot
```

### Contributing

1. Design docs in `design/` - update before implementing
2. User docs in `docs/` - update after implementing
3. Scripts in `scripts/` - imported via `scripts/default.nix`

## See Also

- [User Guide](docs/PORTABLE_BOOT_GUIDE.md) - End-user documentation
- [Architecture](design/ARCHITECTURE.md) - Technical details
- [Features](design/FEATURES.md) - Roadmap and planned features
- [Decisions](design/DECISIONS.md) - Design decision log
