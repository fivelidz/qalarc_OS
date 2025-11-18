# qalarc_OS Welcome Window

First-boot welcome application for qalarc_OS featuring hardware verification, AI model wizard, system tour, and status monitoring.

---

## Overview

A Qt6/QML application using the Kirigami framework that provides an intuitive introduction to qalarc_OS. Launches automatically on first boot and guides users through system verification and setup.

### Features

- **Hardware Verification**: Detect and verify CPU, GPU, RAM, and VRAM configuration
- **AI Model Wizard**: Browse, select, and download AI models with VRAM validation
- **Quick Tour**: Learn about qalarc_OS features and tools
- **System Status**: Monitor services, resources, and system health
- **Catppuccin Theme**: Beautiful Mocha color scheme matching the system

---

## Architecture

### Technology Stack

- **Frontend**: Qt6 + QML + Kirigami
- **Backend**: Python (PyQt6)
- **Styling**: KDE's org.kde.desktop style
- **Integration**: Ollama API, systemd, ROCm tools

### Components

```
qalarc-welcome/
├── main.py                 # Application entry point
├── backend.py              # Python business logic
│   ├── HardwareBackend     # Hardware detection
│   ├── ModelBackend        # AI model management
│   └── SystemBackend       # System status monitoring
├── main.qml                # Main window and navigation
├── pages/                  # QML page components
│   ├── HardwarePage.qml    # Hardware verification screen
│   ├── ModelsPage.qml      # Model download wizard
│   ├── TourPage.qml        # System tour
│   └── StatusPage.qml      # Status dashboard
└── requirements.txt        # Python dependencies
```

---

## Installation

### NixOS (Recommended)

Add to `/etc/nixos/configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  # Qt6/QML dependencies
  qt6.full
  kdePackages.kirigami

  # Python dependencies
  python312Packages.pyqt6
  python312Packages.requests

  # System tools (likely already installed)
  rocmPackages.rocm-smi
  ollama
];
```

### Manual Setup

```bash
# Install Python dependencies
pip install -r requirements.txt

# Make executable
chmod +x main.py
```

---

## Usage

### Run Manually

```bash
cd ~/projects/qalarc-welcome
./main.py
```

### Auto-Launch on First Boot

The welcome window is designed to launch automatically on first boot. It creates a marker file (`~/.config/qalarc-welcome-shown`) to prevent repeated launches.

**Setup Auto-Launch**:

1. Copy desktop file to autostart:
```bash
mkdir -p ~/.config/autostart
cp qalarc-welcome.desktop ~/.config/autostart/
```

2. First boot detection:
   - Application checks for `~/.config/qalarc-welcome-shown`
   - If not present → launches welcome window
   - If present → skips (already shown)

3. Manual reset (to show again):
```bash
rm ~/.config/qalarc-welcome-shown
```

---

## Screens

### 1. Welcome Screen

**Purpose**: Navigation hub to all features

**Features**:
- Beautiful Catppuccin-themed banner
- Four navigation cards:
  - Hardware Verification (blue)
  - AI Model Downloads (green)
  - Quick Tour (yellow)
  - System Status (purple)
- "Skip Welcome" option to disable future launches

---

### 2. Hardware Verification

**Purpose**: Verify system configuration for AI workloads

**Checks**:
- **CPU**: Model, vendor (AMD Ryzen AI MAX+ detection)
- **GPU**: Model, vendor (AMD GPU detection for ROCm)
- **RAM**: Total system memory
- **VRAM**: Allocated VRAM (critical for AI models)

**VRAM Status Indicators**:
- ✓ **Excellent (90GB+)**: "Ready for 70B+ models"
- ⚠ **Good (60-89GB)**: "Can improve to 96GB"
- ⚠ **Low (<60GB)**: "BIOS configuration needed"

**Actions**:
- View BIOS Setup Guide
- Refresh hardware detection
- Continue to model downloads

---

### 3. AI Model Wizard

**Purpose**: Guide users through downloading AI models

**Features**:
- **VRAM-Aware Recommendations**: Shows models compatible with detected VRAM
- **Categorized Models**:
  - Large Models (70B+) - Only shown if VRAM >= 90GB
  - Coding Specialists - DeepSeek Coder, Code Llama
  - Lightweight Models - Always available
- **Model Information**:
  - Name and provider
  - Description and use cases
  - Size (download) and VRAM required
  - Installation status
- **One-Click Downloads**: Direct Ollama integration
- **Quick Actions**: Launch oterm or Open WebUI

**Model Database**:
Pulls from `~/projects/model-manager/model-database.json`

---

### 4. Quick Tour

**Purpose**: Introduce qalarc_OS features and tools

**Sections**:
- **Ghostty Terminal**: GPU-accelerated terminal with AI welcome
- **AI Tools**: oterm, Ollama, Open WebUI, llama.cpp
- **BTRFS Snapshots**: Automatic system backup and recovery
- **Development Environment**: VSCode, languages, containers
- **Project Structure**: Organized folder layout
- **Documentation**: Links to guides and references

**Interactive**: Buttons to launch tools and open folders

---

### 5. System Status

**Purpose**: Monitor system health and services

**Monitors**:
- **System Info**: Hostname, username, NixOS generation
- **Services**:
  - Ollama (with start button if stopped)
  - Docker
  - Open WebUI
- **Resources**:
  - Disk usage with progress bar
  - RAM allocation
  - VRAM allocation
- **Quick Actions**: Launch terminal, monitors, file manager

**Real-Time Updates**: Refreshes every 5 seconds

---

## Backend API

### HardwareBackend

```python
# Properties (read-only)
hardware.cpuModel          # str: CPU model name
hardware.gpuModel          # str: GPU model name
hardware.ramTotalGB        # int: Total RAM in GB
hardware.vramGB            # int: Allocated VRAM in GB
hardware.vramStatus        # str: "excellent", "good", "low", "unknown"
hardware.vramRecommendation # str: Human-readable recommendation
hardware.compatible        # bool: Overall system compatibility

# Methods
hardware.detectHardware()  # Re-run detection
```

### ModelBackend

```python
# Properties
models.availableModels     # list: All available models
models.installedModels     # list: Currently installed models

# Methods
models.loadModels()                    # Load model database
models.downloadModel(model_name)       # Download via Ollama
models.isModelInstalled(model_name)    # Check if installed
models.getModelsForVRAM(vram_gb)       # Filter by VRAM
```

### SystemBackend

```python
# Properties (auto-updating)
systemBackend.ollamaRunning      # bool: Ollama service status
systemBackend.diskUsagePercent   # int: Disk usage (0-100)
systemBackend.generation         # str: NixOS generation number

# Methods
systemBackend.updateStatus()     # Manual refresh
systemBackend.startOllama()      # Start Ollama service
systemBackend.getUsername()      # Current user
systemBackend.getHostname()      # System hostname
```

---

## Customization

### Colors (Catppuccin Mocha)

```qml
// Primary colors used in UI
"#89b4fa"  // Blue (hardware, info)
"#a6e3a1"  // Green (models, success)
"#f9e2af"  // Yellow (tour, warnings)
"#cba6f7"  // Purple (status, advanced)
"#f38ba8"  // Red (errors, critical)

// Background/Surface
"#1e1e2e"  // Base (dark background)
"#313244"  // Surface0 (cards)
"#45475a"  // Surface1 (dividers)

// Text
"#cdd6f4"  // Text (primary)
"#a6adc8"  // Subtext (secondary)
```

### Add Custom Page

1. Create QML file in `pages/`:
```qml
// pages/MyPage.qml
import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    title: "My Custom Page"

    // Your content here
}
```

2. Add to `main.qml`:
```qml
Component {
    id: myPageComponent
    MyPage {}
}

// Add navigation button
Button {
    text: "My Page"
    onClicked: pageStack.push(myPageComponent)
}
```

---

## Model Database Format

Located at: `~/projects/model-manager/model-database.json`

```json
{
  "models": [
    {
      "name": "llama3.3:70b",
      "full_name": "Llama 3.3 70B",
      "provider": "Meta",
      "size_gb": 40,
      "vram_required": 70,
      "parameters": "70B",
      "quantization": "Q8",
      "category": "general",
      "tags": ["chat", "reasoning"],
      "description": "...",
      "recommended": true,
      "use_cases": [...],
      "ollama_pull": "ollama pull llama3.3:70b"
    }
  ],
  "categories": {...},
  "vram_profiles": {...}
}
```

**Edit to add models**: Simply add new entries to the `models` array

---

## Development

### Prerequisites

```bash
# NixOS packages needed
qt6.full
kdePackages.kirigami
python312Packages.pyqt6
python312Packages.requests
```

### Run in Development Mode

```bash
# With verbose output
python -u main.py

# Debug QML
QML_IMPORT_TRACE=1 ./main.py
QT_LOGGING_RULES="*.debug=true" ./main.py
```

### Testing

```bash
# Test hardware detection
~/projects/usb-installer/detect-hardware.sh --human

# Test Ollama connection
curl http://localhost:11434/api/tags

# Test model database
cat ~/projects/model-manager/model-database.json | jq '.models[].name'
```

---

## Troubleshooting

### Window Doesn't Launch

**Issue**: Application exits immediately

**Solutions**:
- Check if PyQt6 is installed: `python -c "import PyQt6"`
- Verify QML file exists: `ls main.qml`
- Run with errors visible: `python -u main.py`

### Hardware Not Detected

**Issue**: Shows "0 GB" or "Unknown"

**Solutions**:
- Ensure ROCm tools installed: `rocm-smi --version`
- Run detection script directly: `~/projects/usb-installer/detect-hardware.sh`
- Check permissions: May need `sudo` for some hardware info

### Models Not Downloading

**Issue**: Download button does nothing

**Solutions**:
- Verify Ollama is running: `systemctl status ollama`
- Check Ollama is accessible: `curl http://localhost:11434`
- Start Ollama manually: `sudo systemctl start ollama`
- Check console for errors: Run app from terminal

### Kirigami Style Not Loading

**Issue**: UI looks plain, not KDE-styled

**Solutions**:
- Ensure Kirigami installed: `nix-shell -p kdePackages.kirigami`
- Set QT_PLUGIN_PATH if needed
- Verify in `main.py`: `QQuickStyle.setStyle("org.kde.desktop")`

---

## Integration with System

### First Boot Flow

1. User boots qalarc_OS for first time
2. Ghostty terminal opens with AI welcome script
3. qalarc Welcome Window auto-launches (via `.desktop` file)
4. User navigates through:
   - Hardware verification
   - Model downloads (optional)
   - Tour (optional)
   - Status check
5. User clicks "Skip Welcome (Don't show again)"
6. Marker file created: `~/.config/qalarc-welcome-shown`
7. Future boots skip welcome window

### Interaction with Other Tools

- **Ollama**: Direct API integration for model management
- **ROCm**: Uses `rocm-smi` for VRAM detection
- **systemd**: Service status monitoring
- **Model Database**: Shared JSON with other tools
- **Documentation**: Links to existing MD files

---

## Future Enhancements

Potential improvements (not yet implemented):

- **Progress Bars**: Real-time download progress for models
- **Model Comparison**: Side-by-side comparison tool
- **Benchmark Results**: Show performance metrics
- **Custom Model URLs**: Add external model sources
- **Resource Graphs**: Live CPU/GPU/RAM charts
- **Snapshot Manager**: GUI for BTRFS snapshots
- **Profile Switcher**: Switch between AI/Gaming profiles
- **Community Profiles**: Download configs from online repo

---

## Resources

- **Qt6 Documentation**: https://doc.qt.io/qt-6/
- **Kirigami Guide**: https://develop.kde.org/frameworks/kirigami/
- **PyQt6 Reference**: https://www.riverbankcomputing.com/static/Docs/PyQt6/
- **Ollama API**: https://github.com/ollama/ollama/blob/main/docs/api.md
- **ROCm Docs**: https://rocm.docs.amd.com/

---

**Version**: 1.0.0
**Last Updated**: 2025-11-17
**Compatible With**: qalarc_OS Phase 7+
**License**: Use within qalarc_OS
