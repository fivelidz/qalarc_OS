# Qalarc AI-OS Branch Strategy

## Branch Overview

| Branch | Purpose | Status |
|--------|---------|--------|
| `main` | Stable releases | Production |
| `full-featured` | Primary development branch | Active |
| `minimal-boot` | Quick bootstrap/debugging build | Maintenance |

## Branch Descriptions

### `main`
- Stable, tested releases only
- Merged from `full-featured` after QA
- Used for production deployments

### `full-featured` (Primary Development)
- The main development branch
- Contains all features for 128GB+ systems
- Hardware detection adapts to available resources
- Low-RAM systems get a notice but still have all other features

### `minimal-boot`
- Minimal configuration to get a system booting
- Used for debugging and initial hardware bring-up
- Not for regular use

## Hardware Detection (Not Separate Branches)

Rather than separate branches for different hardware, **Qalarc uses runtime hardware detection**:

```
RAM >= 120GB  →  "High" tier    →  405B models, full knowledge base
RAM >= 60GB   →  "Medium" tier  →  70B models recommended
RAM >= 30GB   →  "Low" tier     →  7B-13B models
RAM < 30GB    →  "Minimal" tier →  Cloud AI only (Claude Code)
```

All tiers get the **same features**:
- KDE Plasma desktop (or XFCE for mini-pc-low-end)
- Theme selection (Qalarc Dark, Gruvbox, Nord, macOS, Windows)
- Claude Code (cloud-based)
- OpenCode (local models)
- Signal CLI & WhatsApp
- Development tools
- Media applications
- Messaging applications

The only difference: systems with < 30GB RAM see a notice that local AI models aren't recommended, but they can still try if they want.

## Host Configurations

| Config | Target Hardware | Desktop |
|--------|-----------------|---------|
| `gmktec-01` | 128GB EVO-X2 (dual-drive) | KDE Plasma 6 |
| `gmktec-01-single-drive` | 128GB EVO-X2 (single-drive) | KDE Plasma 6 |
| `gmktec-01-minimal` | 128GB EVO-X2 (debugging) | KDE Plasma 6 |
| `mini-pc-low-end` | 8-32GB mini PCs | XFCE (lighter) |
| `installer` | Live USB installer | - |

## Development Workflow

1. Feature development happens on `full-featured`
2. Test on actual hardware
3. When stable, merge to `main`
4. Tag releases on `main`

```bash
# Typical workflow
git checkout full-featured
# ... make changes ...
git commit -m "feat: add new feature"
git push origin full-featured

# When ready for release
git checkout main
git merge full-featured
git tag v1.0.0
git push origin main --tags
```

## Building

```bash
# Build for 128GB systems
nix build .#nixosConfigurations.gmktec-01.config.system.build.toplevel

# Build for low-end systems
nix build .#nixosConfigurations.mini-pc-low-end.config.system.build.toplevel

# Build installer ISO
nix build .#nixosConfigurations.installer.config.system.build.isoImage
```
