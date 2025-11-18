# qalarc_OS Projects

**AI-Powered Workstation Operating System for AMD Hardware**

This repository contains the core projects for qalarc_OS, including the installation system, welcome window, and AI model management tools.

---

## 🚀 Quick Start

### For New Users

1. **Download Installation ISO** (when available)
2. **Write to USB**: `sudo dd if=qalarc-os.iso of=/dev/sdX bs=4M`
3. **Boot from USB** and run `qalarc-install`
4. **Follow guided setup** with profile selection

### For Developers

```bash
# Clone repository
git clone https://github.com/qalarc/qalarc_OS.git ~/projects

# Explore projects
cd ~/projects
ls -la
```

---

## 📦 Projects

### [USB Installer](usb-installer/)
Interactive installation system with profile-based configuration.

- **installer.sh** - Main installation script
- **detect-hardware.sh** - Hardware detection tool
- **build-iso.sh** - ISO generation
- **profiles/** - AI Workstation, Gaming+AI, Base

[📖 Read Full Documentation →](usb-installer/README.md)

---

### [Welcome Window](qalarc-welcome/)
Qt/QML first-boot application for system onboarding.

- **Hardware Verification** - GPU, VRAM, system checks
- **AI Model Wizard** - Download and manage LLMs
- **Quick Tour** - Learn about features
- **System Status** - Monitor services

[📖 Read Full Documentation →](qalarc-welcome/README.md)

---

### [Model Manager](model-manager/)
AI model database and metadata.

- **model-database.json** - Comprehensive model catalog
- 12 models with metadata (size, VRAM, use cases)
- VRAM profiles for different hardware

---

## 🎯 Features

### Installation System
- ✅ Profile-based installation (AI Workstation, Gaming+AI, Base)
- ✅ Interactive dialog-based UI
- ✅ Automated hardware detection
- ✅ VRAM verification and recommendations
- ✅ Bootable ISO creation

### Welcome Window
- ✅ Beautiful Qt/QML interface with Kirigami
- ✅ Hardware verification with color-coded status
- ✅ AI model download wizard
- ✅ System tour and documentation
- ✅ Live status monitoring

### AI/ML Stack
- ✅ Ollama with ROCm acceleration
- ✅ oterm terminal UI
- ✅ Open WebUI (web interface)
- ✅ llama.cpp for GGUF models
- ✅ Python ML stack (PyTorch, Transformers)

---

## 🖥️ Hardware Support

### Optimized For
- **CPU**: AMD Ryzen AI MAX+ series
- **GPU**: Radeon 8060S (integrated, RDNA 3.5)
- **RAM**: 128GB LPDDR5X
- **VRAM**: Up to 96GB allocation (UMA)

### Requirements
- **Minimum**: AMD Ryzen CPU, 32GB RAM, AMD GPU
- **Recommended**: Ryzen AI MAX+ 395, 128GB RAM, 96GB VRAM
- **Storage**: 100GB+ (2TB+ recommended for models)

---

## 📚 Documentation

- [USB Installer Guide](usb-installer/README.md)
- [Welcome Window Guide](qalarc-welcome/README.md)
- [BIOS Setup (96GB VRAM)](../Documents/qalarc-os-setup/BIOS-SETUP-GUIDE.md)
- [Phase 8 Summary](../Documents/qalarc-os-setup/PHASE8-INSTALLER-SUMMARY.md)
- [Phase 7 Summary](../Documents/qalarc-os-setup/PHASE7-COMPLETE-SUMMARY.md)

---

## 🛠️ Installation Profiles

### AI Workstation (Recommended)
Full AI/ML development stack with ROCm, Ollama, PyTorch, and all development tools.

**Best for**: AI developers, researchers, ML engineers

**Includes**: 130+ packages including ROCm, Ollama, oterm, Docker, VSCode, Python ML stack

---

### Gaming + AI
Everything from AI Workstation plus gaming tools.

**Best for**: Gamers who also want AI capabilities

**Adds**: Steam, Lutris, Heroic, GameMode, MangoHud, Wine, Discord

---

### Base System
Minimal KDE Plasma system for custom builds.

**Best for**: Advanced users, servers, custom configurations

**Includes**: Core tools, development environment, BTRFS snapshots

---

## 🚀 Quick Commands

### Installation
```bash
# Build ISO
cd ~/projects/usb-installer
./build-iso.sh

# Detect hardware
./detect-hardware.sh --human

# Run installer (from live USB)
qalarc-install
```

### Welcome Window
```bash
# Launch manually
cd ~/projects/qalarc-welcome
./main.py

# Reset first-boot flag
rm ~/.config/qalarc-welcome-shown
```

### AI Models
```bash
# Download models (after VRAM configuration)
ollama pull llama3.3:70b
ollama pull deepseek-coder:33b

# Launch terminal UI
oterm

# Check VRAM
rocm-smi --showmeminfo vram
```

---

## 🔧 Development

### Prerequisites (NixOS)

```nix
environment.systemPackages = with pkgs; [
  # Installer
  dialog
  parted
  nixos-generators

  # Welcome Window
  qt6.full
  kdePackages.kirigami
  python312Packages.pyqt6
  python312Packages.requests

  # AI Tools
  ollama
  oterm
  llama-cpp
  rocmPackages.rocm-smi
];
```

### Project Structure

```
projects/
├── usb-installer/         # Installation system
│   ├── installer.sh
│   ├── detect-hardware.sh
│   ├── build-iso.sh
│   └── profiles/
├── qalarc-welcome/        # Welcome window
│   ├── main.py
│   ├── backend.py
│   ├── main.qml
│   └── pages/
├── model-manager/         # Model database
│   └── model-database.json
└── ai-terminal/           # (Future) Custom TUI
```

---

## 🤝 Contributing

qalarc_OS is designed for personal use but contributions to improve hardware detection, add model support, or enhance the installer are welcome.

### Adding Models

Edit `model-manager/model-database.json`:

```json
{
  "name": "model-name",
  "full_name": "Model Full Name",
  "provider": "Provider",
  "size_gb": 40,
  "vram_required": 70,
  "category": "general",
  "description": "...",
  "ollama_pull": "ollama pull model-name"
}
```

---

## 📊 Statistics

- **19 Files Created** in Phase 8
- **5,347 Lines of Code**
- **3 Installation Profiles**
- **12 AI Models** in database
- **4 Welcome Window Screens**

---

## 🎯 Roadmap

### Phase 8 (Current) ✅
- ✅ Text-based installer
- ✅ ISO generation
- ✅ Welcome window application
- ✅ Model database

### Phase 9 (Planned)
- [ ] Portable/external drive support
- [ ] Online profile repository
- [ ] GUI installer (Calamares)
- [ ] Model benchmarking tool
- [ ] Snapshot management GUI

### Future
- [ ] Multi-language support
- [ ] Disk encryption option
- [ ] Network installation
- [ ] Cloud profile sync

---

## 📄 License

Built for personal use on qalarc_OS. Components use their respective open-source licenses.

---

## 🔗 Links

- **Documentation**: `~/Documents/qalarc-os-setup/`
- **Ideas & Roadmap**: `~/claude/OM/ideas/`
- **System Config**: `/etc/nixos/configuration.nix`

---

**Version**: Phase 8 (Generation 15)
**Last Updated**: 2025-11-17
**Built With**: NixOS, Qt6, Python, Bash
**Optimized For**: AMD Ryzen AI MAX+ with ROCm

---

🎉 **Welcome to qalarc_OS - AI-Powered Computing on AMD Hardware**
