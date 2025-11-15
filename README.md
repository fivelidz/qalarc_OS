# qalarc_OS

**Production-ready NixOS deployment system for AMD Ryzen AI Max+ 395 systems**

A reproducible, high-performance operating system designed for AI/ML workloads on GMKTEC EVO-X2 AI mini PCs and similar AMD Ryzen AI Max+ hardware.

[![NixOS](https://img.shields.io/badge/NixOS-25.05-blue.svg)](https://nixos.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

---

## 🎯 Key Features

- **🔄 Reproducible**: Declarative NixOS configuration - same config = identical system every time
- **⚡ Performance**: CachyOS kernel + architecture-specific optimizations for AI workloads
- **🤖 AI-First**: Pre-configured Ollama, PyTorch, ROCm for 96GB unified memory
- **💾 Resilient**: BTRFS snapshots with GRUB boot menu - roll back any change
- **🖥️ User-Friendly**: KDE Plasma 6 with tiling (Windows-familiar interface)
- **🌐 Remote Ready**: Tailscale VPN, SSH, streaming built-in
- **🔧 AI-Assisted**: TMUX workspace with local coding models (Qwen, etc.)

---

## 📊 System Specifications

Optimized for **GMKTEC EVO-X2 AI** and compatible systems:

| Component | Specification |
|-----------|---------------|
| **CPU** | AMD Ryzen AI Max+ 395 (16-core Zen 5, up to 5.1 GHz) |
| **NPU** | XDNA2 (50 TOPS AI, 126 TOPS total) |
| **GPU** | AMD Radeon 8060S (40 RDNA 3.5 CUs) |
| **Memory** | 128GB LPDDR5X-8000 (unified architecture) |
| **VRAM** | Up to 96GB via UMA (configurable in BIOS) |
| **Storage** | NVMe M.2 SSD (BTRFS with compression) |

---

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/fivelidz/qalarc_OS.git
cd qalarc_OS
```

### 2. Create Bootable USB

```bash
./scripts/create-usb-installer.sh /dev/sdX  # Replace with your USB device
```

### 3. Install NixOS

Boot from USB and follow the installation guide: [docs/INSTALLATION.md](./docs/INSTALLATION.md)

### 4. Post-Install Configuration

```bash
# Configure 96GB VRAM in BIOS (see docs/UMA-CONFIGURATION.md)
# Boot into NixOS
./scripts/check-uma-allocation.sh  # Verify VRAM

# Launch AI coding workspace (similar to Claude Code)
qalarc-ai-workspace
```

---

## 📁 Repository Structure

```
qalarc_OS/
├── flake.nix                 # Nix flake configuration
├── hosts/                    # Machine-specific configs
│   ├── gmktec-01/           # First deployment
│   └── template/            # Template for new machines
├── modules/                  # Reusable NixOS modules
│   ├── desktop/             # KDE Plasma 6 + Krohnkite tiling
│   ├── ai-ml/               # Ollama, PyTorch, ROCm
│   ├── snapper/             # BTRFS snapshots + GRUB
│   ├── networking/          # Tailscale, SSH, streaming
│   ├── development/         # VSCode, Neovim, Git, TMUX
│   ├── media/               # Browsers, FFmpeg, graphics
│   └── system-monitor/      # Conky, btop, system stats
├── overlays/
│   └── performance.nix      # -march=native optimizations
├── scripts/
│   ├── qalarc-ai-workspace.sh      # AI coding assistant
│   ├── check-uma-allocation.sh     # Verify VRAM config
│   ├── create-usb-installer.sh     # Build bootable USB
│   └── deploy.sh                   # Deploy to machine
└── docs/                    # Comprehensive documentation
    ├── INSTALLATION.md      # Step-by-step install guide
    ├── UMA-CONFIGURATION.md # 96GB VRAM setup
    ├── LLM-SETUP.md         # AI model hosting
    ├── ARCHITECTURE.md      # System design (LLM-friendly)
    └── DECISIONS.md         # Design rationale
```

---

## 🧠 AI Coding Workspace

qalarc_OS includes a TMUX-based coding environment similar to Claude Code, but using **100% local models**:

```bash
qalarc-ai-workspace  # Launch AI coding assistant
```

**Features:**
- 🤖 Local Qwen 32B coder model (or your choice)
- 📊 Live system monitoring (btop, GPU stats)
- 🔧 Command runner for AI-suggested code
- 📝 Full system context (NixOS config, hardware info)
- 🎨 Customizable appearance (TMUX config)

**Default Layout:**
```
┌─────────────────────────────────────────┬──────────────┐
│                                         │              │
│   AI Chat (Qwen/Local Model)          │   System     │
│                                         │   Monitor    │
│                                         │   (btop)     │
│                                         │              │
├─────────────────────────────────────────┼──────────────┤
│   Command Runner / File Viewer          │              │
└─────────────────────────────────────────┴──────────────┘
```

---

## 🎛️ Desktop Environment

**KDE Plasma 6** with **Krohnkite tiling** extension:

- ✅ Windows-familiar interface (taskbar, start menu, system tray)
- ✅ Tiling window management (vim-style shortcuts)
- ✅ Point-and-click configuration (no text files required)
- ✅ Conky overlay with UMA stats, GPU usage, AI service status

**Tiling Shortcuts:**
- `Meta+T` - Toggle tiling mode
- `Meta+J/K/H/L` - Navigate windows (vim-style)
- `Meta+Shift+J/K/H/L` - Move windows
- `Super+Shift+S` - Create manual snapshot

---

## 📦 Included Software

<details>
<summary><b>AI/ML Stack</b></summary>

- **LLM Servers:** Ollama (REST API), llama.cpp
- **Frameworks:** PyTorch (ROCm), Transformers, Hugging Face CLI
- **Tools:** ROCm-SMI, rocminfo, Python 3.12 ML stack
- **Models:** Stored in `/local-llms/` (BTRFS compressed)

</details>

<details>
<summary><b>Development Tools</b></summary>

- **Editors:** VSCode, Neovim, Vim
- **Terminal:** Ghostty, TMUX
- **Version Control:** Git, GitHub CLI (gh), Lazygit
- **Languages:** Python, Node.js, Rust, Go
- **Containers:** Docker, Podman
- **Utilities:** jq, ripgrep, fd, bat, fzf, direnv

</details>

<details>
<summary><b>Media & Browsers</b></summary>

- **Browsers:** Brave, Google Chrome, Firefox
- **Video:** VLC, MPV, Kdenlive, OBS Studio
- **Graphics:** GIMP, Inkscape, Krita
- **Conversion:** FFmpeg (full codecs), Handbrake, qalarc-convert helper

</details>

<details>
<summary><b>Remote Access</b></summary>

- **VPN:** Tailscale (zero-config mesh), WireGuard, OpenVPN
- **Streaming:** Sunshine (desktop streaming to Moonlight)
- **SSH:** OpenSSH server (key-based auth)
- **Phone:** KDE Connect integration

</details>

---

## 📸 Snapshots & Recovery

Automatic BTRFS snapshots with **Snapper** + **GRUB integration**:

- ✅ Snapshots before every `nixos-rebuild`
- ✅ Daily automatic snapshots (configurable retention)
- ✅ Manual snapshots via `Super+Shift+S` or `qalarc-snapshot`
- ✅ Boot into any snapshot from GRUB menu
- ✅ One-command rollback: `snapper rollback <number>`

**Retention Policy:**
- Hourly: 24 snapshots (1 day)
- Daily: 7 snapshots (1 week)
- Weekly: 4 snapshots (1 month)
- Monthly: 6 snapshots (6 months)
- Pre/post updates: 10 snapshots

**Estimated storage:** 20-50GB on 128GB system

---

## ⚡ Performance Optimizations

qalarc_OS balances **reproducibility** with **performance**:

### What's Optimized

✅ **CachyOS Kernel** (via Chaotic-Nyx)
  - BORE scheduler for better responsiveness
  - x86-64-v3 optimizations
  - Low-latency patches

✅ **Critical AI Packages** (`overlays/performance.nix`)
  - llama.cpp: `-march=native -O3`
  - PyTorch: ROCm backend
  - Ollama: ROCm integration
  - BLAS/LAPACK: Intel MKL (faster than generic)

✅ **96GB UMA VRAM** (kernel 6.16.9+ auto-detects)
  - Full unified memory for AI workloads
  - No manual kernel parameters needed

### Performance vs. CachyOS

| Metric | Target |
|--------|--------|
| LLM Inference | Within 10% of CachyOS |
| System Responsiveness | Comparable |
| Build Reproducibility | 100% (CachyOS ~70%) |

See [docs/PERFORMANCE.md](./docs/PERFORMANCE.md) for benchmarks.

---

## 🛠️ System Administration

### Update System

```bash
cd ~/qalarc_OS
nix flake update               # Update dependencies
sudo nixos-rebuild switch --flake .#gmktec-01
```

### Manage Snapshots

```bash
snapper list                   # List all snapshots
qalarc-snapshot "description"  # Create manual snapshot
snapper rollback 42            # Rollback to snapshot 42
# Or boot into snapshot from GRUB menu
```

### Check System Status

```bash
cat /var/lib/qalarc/system-state.json | jq  # Full system state
./scripts/check-uma-allocation.sh            # Verify VRAM
qalarc-network-status                        # Network info
rocm-smi                                     # GPU stats
```

### AI Assistant Interface

All scripts output JSON for easy parsing by local AI coding models:

```bash
# System state
cat /var/lib/qalarc/system-state.json

# GPU stats
cat /var/lib/qalarc/gpu-stats.json

# Network status
qalarc-network-status

# Snapshots
snapper list --json
```

---

## 📚 Documentation

Comprehensive documentation in `docs/`:

| Document | Description |
|----------|-------------|
| [INSTALLATION.md](./docs/INSTALLATION.md) | Step-by-step installation guide |
| [UMA-CONFIGURATION.md](./docs/UMA-CONFIGURATION.md) | 96GB VRAM setup (BIOS + kernel) |
| [LLM-SETUP.md](./docs/LLM-SETUP.md) | Deploy AI models, Ollama, inference |
| [REMOTE-ACCESS.md](./docs/REMOTE-ACCESS.md) | Tailscale, SSH, streaming setup |
| [ARCHITECTURE.md](./docs/ARCHITECTURE.md) | System design (LLM-friendly format) |
| [DECISIONS.md](./docs/DECISIONS.md) | Design decisions with rationale |
| [PERFORMANCE.md](./docs/PERFORMANCE.md) | Benchmarks & optimization guide |

---

## 🤝 Contributing

This is a personal deployment system, but contributions are welcome!

1. Fork the repository
2. Create a feature branch
3. Test on your hardware
4. Submit a pull request

---

## 📄 License

MIT License - See [LICENSE](./LICENSE) file for details.

---

## 🙏 Acknowledgments

- **NixOS** community for the amazing reproducible build system
- **CachyOS** for performance kernel optimizations
- **nixified.ai** for AI package inspiration
- **AMD** for the incredible Ryzen AI Max+ 395 hardware

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/fivelidz/qalarc_OS/issues)
- **Discussions:** [GitHub Discussions](https://github.com/fivelidz/qalarc_OS/discussions)

---

**Built with ❤️ for reproducible, high-performance AI workloads**

*Last updated: 2025-11-15*
