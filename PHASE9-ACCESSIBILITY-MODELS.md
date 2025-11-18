# Phase 9+: Accessibility, Model Marketplace & Advanced Inference

**Status**: Planning
**Priority**: High
**Target**: Future releases

---

## 🦾 Accessibility Features

### Eye Tracking Integration

**Goal**: Full system control via eye tracking for accessibility

**Components**:
1. **Eye Tracking Hardware Support**
   - Tobii Eye Tracker support
   - Camera-based tracking (using existing webcam)
   - Calibration system for accuracy

2. **Calibration Interface**
   - Multi-point calibration screen
   - Accuracy testing and adjustment
   - Per-user calibration profiles
   - Save/restore calibration data

3. **Eye Control Features**
   - Mouse cursor control
   - Click gestures (dwell time, blink detection)
   - Scroll control
   - Window/workspace switching
   - Keyboard overlay for text input

4. **Implementation Stack**
   - **Linux**: evdev, uinput for input injection
   - **Libraries**:
     - PyGaze (eye tracking framework)
     - OpenCV (camera-based tracking)
     - Tobii SDK (if using Tobii hardware)
   - **Integration**: KDE Plasma accessibility layer

**Configuration Location**: `~/.config/qalarc-accessibility/eye-tracking/`

---

### Voice Commands & Speech Integration

**Goal**: Full voice control and dictation for hands-free operation

**Components**:
1. **Wake Word Detection**
   - "Hey qalarc" or custom wake word
   - Always-on listening (privacy-preserving)
   - Local processing (no cloud)

2. **Voice Commands**
   - System control: "Open terminal", "Launch browser"
   - Window management: "Maximize", "Split screen"
   - Application commands: "Run ollama", "Start code editor"
   - Model interaction: "Ask llama 70B", "Generate code with deepseek"

3. **Speech-to-Text**
   - Dictation mode for text input
   - Real-time transcription
   - Multi-language support
   - Integration with text editors

4. **Text-to-Speech**
   - Read model responses aloud
   - System notifications
   - Screen reader integration
   - Natural voice synthesis

5. **Implementation Stack**
   - **Wake Word**: Porcupine (on-device)
   - **STT (Speech-to-Text)**:
     - Whisper (OpenAI) - local inference
     - Faster-Whisper (optimized for CPU/GPU)
     - Vosk (lightweight alternative)
   - **TTS (Text-to-Speech)**:
     - Piper TTS (local, fast, natural)
     - Coqui TTS (open-source)
   - **Voice Activity Detection**: WebRTC VAD

**Privacy**:
- ✅ All processing local (no cloud)
- ✅ Audio only captured when wake word detected
- ✅ No persistent recording
- ✅ User-controlled activation

**Configuration Location**: `~/.config/qalarc-accessibility/voice/`

---

## 🏪 Model Marketplace App

**Goal**: Beautiful, user-friendly interface for model management

### Core Features

1. **Model Library View**
   - **Installed Models**:
     - Name, size, VRAM requirement
     - Last used timestamp
     - Performance metrics (tokens/sec)
     - Quick actions: Run, Delete, Update
   - **Available Models**:
     - Categorized by: General, Coding, Math, Lightweight, Specialized
     - Filter by VRAM requirement
     - Sort by: Size, Performance, Popularity
     - One-click download with progress

2. **Model Details Page**
   - Full description
   - Use cases and strengths
   - Example prompts
   - Benchmark results
   - VRAM/RAM requirements
   - Download size
   - Community ratings
   - Related models

3. **Chat Interface**
   - **Terminal Integration**: Launch from marketplace or terminal
   - **Persistent Chats**: Auto-saved as markdown
   - **Chat Management**:
     - List all chats by model
     - Search chat history
     - Export/import chats
     - Share chats (markdown export)
   - **Multi-Model Comparison**: Side-by-side chat with different models

4. **Chat Persistence Architecture**
   ```
   ~/Models/chats/
   ├── llama3.3-70b/
   │   ├── 2025-11-17_conversation-1.md
   │   ├── 2025-11-17_coding-help.md
   │   └── metadata.json
   ├── deepseek-coder-33b/
   │   ├── 2025-11-15_debug-session.md
   │   └── metadata.json
   └── qwen2.5-72b/
       └── 2025-11-16_research.md
   ```

5. **Markdown Chat Format**
   ```markdown
   # Chat with Llama 3.3 70B
   **Started**: 2025-11-17 14:30:22
   **Model**: llama3.3:70b
   **VRAM Used**: 68GB

   ---

   ## User (14:30:25)
   Explain quantum computing in simple terms

   ## Assistant (14:30:31)
   Quantum computing uses quantum bits (qubits) that can be in multiple states...

   ---

   ## User (14:32:10)
   How does it differ from classical computing?

   ## Assistant (14:32:18)
   Classical computers use binary bits (0 or 1)...
   ```

### UI/UX Design

**Technology Stack**:
- **Framework**: Qt6/QML + Kirigami (consistent with Welcome Window)
- **Backend**: Python + PyQt6
- **Database**: SQLite for chat metadata
- **Theme**: Catppuccin Mocha (system-wide consistency)

**Features**:
- ✅ Dark/light theme support
- ✅ Responsive layout (desktop, touch)
- ✅ Keyboard shortcuts
- ✅ Search and filtering
- ✅ Real-time download progress
- ✅ VRAM monitoring overlay

**Integration Points**:
- Launch from: Desktop menu, Terminal (command: `qalarc-models`), Welcome Window
- Terminal command: `qalarc-chat llama3.3:70b` opens last chat or creates new one
- Auto-save every 30 seconds during chat

---

## ⚡ Fast Small Writing Models

**Goal**: Ultra-fast inference for writing tasks (emails, docs, code comments)

### Target Models (< 3B parameters)

1. **Phi-3 Mini (3.8B)** - Already in database ✅
   - Use case: Fast writing, summarization
   - Speed: ~100 tokens/sec on CPU

2. **Llama 3.2 3B** - Already in database ✅
   - Use case: General writing, chat
   - Speed: ~80 tokens/sec on CPU

3. **Llama 3.2 1B** - Already installed ✅
   - Use case: Autocomplete, quick responses
   - Speed: ~200 tokens/sec on CPU

4. **TinyLlama 1.1B** (NEW - Add to database)
   - VRAM: 1GB
   - Size: 637MB
   - Use case: Real-time autocomplete, instant responses
   - Speed: ~250 tokens/sec on CPU
   - Ollama: `ollama pull tinyllama`

5. **Qwen 2.5 0.5B** (NEW - Add to database)
   - VRAM: 0.5GB
   - Size: 397MB
   - Use case: Ultra-fast writing assistant
   - Speed: ~400 tokens/sec on CPU
   - Multilingual support
   - Ollama: `ollama pull qwen2.5:0.5b`

6. **Stable LM 2 1.6B** (NEW - Add to database)
   - VRAM: 1.6GB
   - Size: 980MB
   - Use case: Chat, creative writing
   - Speed: ~180 tokens/sec on CPU
   - Ollama: `ollama pull stablelm2:1.6b`

### Writing-Optimized Features

**Auto-Completion Engine**:
- Real-time suggestions in text editors
- Context-aware (current file, project)
- VSCode/Neovim integration
- Minimal latency (<100ms)

**Writing Assistants**:
- Email composer with tone adjustment
- Document proofreading
- Code comment generation
- Markdown documentation writer

**Performance Targets**:
- Latency: <50ms for first token
- Throughput: >150 tokens/sec
- VRAM: <2GB for writing models
- CPU fallback: All models run on CPU if VRAM full

---

## 🚀 D2F (Discrete Diffusion Forcing) Integration

**Status**: Research - Experimental

### What is D2F?

**Discrete Diffusion Forcing** is a novel training and inference paradigm for Diffusion Language Models (dLLMs) that achieves **2.5x speedup** over traditional autoregressive models while maintaining quality.

### Key Innovations

1. **Block-Wise Causal Attention**
   - Bidirectional attention within blocks (rich context)
   - Causal attention between blocks (KV cache compatible)
   - Enables parallel processing

2. **Asymmetric Distillation**
   - Student model learns from bidirectional teacher
   - Cache-friendly architecture
   - Maintains generation quality

3. **Pipelined Parallel Decoding**
   - Multiple blocks refined simultaneously
   - Asynchronous workflow
   - Eliminates sequential bottlenecks

### Performance Benefits

**Speed Improvements**:
- ✅ **2.5x faster** than LLaMA3-8B
- ✅ **>50x faster** than vanilla dLLM baselines
- ✅ **6.5x speedup** with vLLM integration (preliminary)

**Quality**:
- ✅ Comparable generation quality on reasoning benchmarks
- ✅ Competitive on coding tasks
- ⚠️ vLLM integration has accuracy tradeoffs (being optimized)

### Available Models

1. **D2F-Dream-Base-7B**
   - Format: LoRA
   - Base: 7B parameters
   - Use case: General tasks

2. **D2F-LLaDA-Instruct-8B** ⭐
   - Format: LoRA
   - Base: 8B parameters
   - Use case: Instruction following, chat
   - Recommended for qalarc_OS

### Integration Challenges

**Current State**:
- ❌ No Ollama support (Hugging Face/vLLM only)
- ❌ No llama.cpp compatibility
- ❌ Requires A100-class GPU for optimal performance
- ❌ Complex setup (Python 3.10+, Hugging Face ecosystem)

**Integration Path**:
1. **Phase 9a**: Hugging Face Transformers integration
   - Install via `transformers` library
   - Python script wrapper
   - Separate from Ollama workflow

2. **Phase 9b**: Performance testing on AMD ROCm
   - Benchmark D2F-LLaDA-8B on Radeon 8060S
   - Compare with standard LLaMA3-8B
   - Measure real-world speedup

3. **Phase 10**: Custom inference server (if viable)
   - FastAPI wrapper around D2F models
   - REST API compatible with Ollama
   - Integrate into model marketplace

**Recommendation**: Monitor D2F development for Ollama/llama.cpp ports. Current integration complexity may not justify speedup for desktop use case.

### Context Window Protocols

**Note**: D2F repository does not discuss context window protocols or sliding window mechanisms. Focus is on architectural speedup, not context management.

For extended context, continue using:
- LongContext models (Qwen 2.5 supports 128k context)
- Sliding window attention (Mistral)
- Standard context management in Ollama

---

## 📊 VRAM Allocation Update

### Required Configuration: 32GB VRAM / 94GB System RAM

**BIOS Setting**: UMA Frame Buffer Size = **32GB**

### Model Capacity with 32GB VRAM

| Model | VRAM Required | Can Run? | Notes |
|-------|--------------|----------|-------|
| **Llama 3.3 70B** | 70GB | ❌ NO | Requires 70GB minimum |
| **Qwen 2.5 72B** | 72GB | ❌ NO | Requires 72GB minimum |
| **Mistral 123B** | 63GB | ❌ NO | Requires 63GB minimum |
| **DeepSeek Coder 33B** | 33GB | ⚠️ TIGHT | Just over limit, may work with optimizations |
| **Qwen 2.5 Coder 32B** | 32GB | ✅ YES | Exact fit |
| **Code Llama 34B** | 34GB | ❌ NO | Slightly over |
| **Mixtral 8x7B** | 45GB | ❌ NO | Requires 45GB |
| **Gemma 2 27B** | 27GB | ✅ YES | Comfortable fit |
| **Phi-3 14B** | 14GB | ✅ YES | Easy fit |
| **Llama 3.2 3B** | 3GB | ✅ YES | Very comfortable |
| **Llama 3.2 1B** | 1GB | ✅ YES | Minimal VRAM |

### Recommended Model Set for 32GB VRAM

**Tier 1 - Primary Models** (Use these daily):
1. **Qwen 2.5 Coder 32B** - Best coding model that fits
2. **Gemma 2 27B** - Strong general-purpose model
3. **Phi-3 14B** - Fast reasoning and writing

**Tier 2 - Specialized Models** (Install as needed):
1. **Llama 3.2 3B** - Fast responses, low VRAM
2. **Llama 3.2 1B** - Ultra-fast, minimal resources
3. **TinyLlama 1.1B** - Autocomplete, instant responses
4. **Qwen 2.5 0.5B** - Writing assistant, ultra-fast

**Trade-offs with 32GB VRAM**:
- ❌ Cannot run 70B+ flagship models (Llama 3.3, Qwen 2.5 72B, Mistral 123B)
- ✅ Can run excellent 30B-class models (Qwen Coder 32B, Gemma 2 27B)
- ✅ Leaves 94GB system RAM for heavy development work
- ✅ Can load multiple small models simultaneously

**Workflow Optimization**:
- Use **Qwen 2.5 Coder 32B** for coding (best that fits)
- Use **Gemma 2 27B** for general chat and reasoning
- Use **Phi-3 14B** for fast writing and summaries
- Use **small models (1B-3B)** for autocomplete and quick tasks
- **CPU Fallback**: Load 70B models on CPU if needed (slow but possible)

### CPU Inference Option

With **94GB System RAM**, you can run 70B models on CPU:

```bash
# Run Llama 3.3 70B on CPU (slow but works)
CUDA_VISIBLE_DEVICES="" ollama run llama3.3:70b

# Or specify CPU explicitly
ollama run --cpu llama3.3:70b
```

**CPU Performance**:
- Speed: ~5-15 tokens/sec (vs 50-100 on GPU)
- VRAM: 0GB (uses system RAM)
- Best for: Non-interactive tasks, batch processing, overnight runs

---

## 🗂️ File Structure Changes

### New Directories
```
~/Models/
├── chats/                    # Persistent chat storage
│   ├── llama3.2-1b/
│   ├── qwen2.5-coder-32b/
│   ├── gemma2-27b/
│   └── metadata.db           # SQLite chat index
├── d2f-models/              # D2F models (if integrated)
│   ├── d2f-llada-8b/
│   └── configs/
└── writing-models/          # Fast writing models

~/.config/qalarc-accessibility/
├── eye-tracking/
│   ├── calibration-profiles/
│   ├── settings.json
│   └── enabled-features.conf
└── voice/
    ├── wake-word-config.json
    ├── voice-commands.json
    └── stt-models/

~/.local/share/qalarc-models/
├── marketplace.db           # Model marketplace database
├── downloads/              # Temporary download storage
└── cache/                  # UI cache
```

---

## 🎯 Implementation Priority

### Phase 9a (High Priority - Next)
1. ✅ Model Marketplace app (6-8 weeks)
   - UI design
   - Backend implementation
   - Chat persistence
   - Markdown export/import

2. ✅ Fast writing models integration (1 week)
   - Add TinyLlama, Qwen 0.5B, Stable LM to database
   - Autocomplete engine
   - Editor integration

3. ✅ Update VRAM documentation (1 day)
   - Change recommendations to 32GB VRAM
   - Update all guides and profiles
   - Add CPU fallback documentation

### Phase 9b (Medium Priority)
1. ⏳ Voice commands (4-6 weeks)
   - Wake word detection
   - Basic system commands
   - STT integration (Whisper)
   - TTS for responses

2. ⏳ D2F model testing (2-3 weeks)
   - Benchmark on ROCm
   - Evaluate vs standard models
   - Integration feasibility study

### Phase 10 (Future)
1. 🔮 Eye tracking integration (6-8 weeks)
   - Hardware support research
   - Calibration system
   - Full accessibility suite

2. 🔮 Advanced marketplace features
   - Community ratings
   - Model fine-tuning UI
   - Multi-model orchestration

---

## 📝 Technical Notes

### Model Marketplace Tech Stack
```
Backend:
  - Python 3.12
  - PyQt6
  - SQLite (chat metadata)
  - Ollama Python SDK

Frontend:
  - Qt6/QML
  - Kirigami
  - Catppuccin Mocha theme

Integration:
  - D-Bus (system notifications)
  - systemd (background service)
  - XDG Desktop Entry (.desktop file)
```

### Voice Integration Dependencies
```nix
environment.systemPackages = with pkgs; [
  # Wake word
  porcupine          # Or use custom training

  # Speech-to-Text
  whisper-cpp        # Optimized Whisper
  faster-whisper     # Python wrapper
  vosk               # Lightweight alternative

  # Text-to-Speech
  piper-tts          # Fast, natural TTS
  coqui-tts          # Alternative TTS

  # Audio
  pulseaudio         # Or pipewire
  alsa-utils

  # Libraries
  python312Packages.sounddevice
  python312Packages.webrtcvad
];
```

---

## 🚀 Quick Commands (Future)

```bash
# Model marketplace
qalarc-models                        # Open marketplace GUI
qalarc-chat qwen2.5-coder:32b       # Open/continue chat with model
qalarc-models install tinyllama      # Install model from CLI

# Voice control
qalarc-voice enable                  # Enable voice commands
qalarc-voice calibrate              # Calibrate wake word
qalarc-voice test                   # Test STT/TTS

# Accessibility
qalarc-eyetrack calibrate           # Calibrate eye tracking
qalarc-eyetrack enable              # Enable eye control
qalarc-accessibility status         # Show all accessibility features

# Fast inference
qalarc-autocomplete enable          # Enable writing autocomplete
qalarc-autocomplete model tinyllama # Set autocomplete model
```

---

## 🍎 MacOS-Style Theme Preset

**Goal**: Provide a one-click theme preset that transforms KDE Plasma to look and feel like macOS

### Visual Components

1. **Global Menu Bar** (Top Panel)
   - Application menu in top panel (like macOS)
   - KDE Plasma Global Menu widget
   - Clock centered in top panel
   - System tray on right

2. **Dock** (Bottom Panel)
   - Latte Dock configured as macOS-style dock
   - Centered at bottom
   - Icons enlarge on hover (parabolic effect)
   - Minimize to dock
   - Trash in dock

3. **Window Decorations**
   - Window buttons on LEFT side (close, minimize, maximize)
   - Traffic light style buttons (red, yellow, green)
   - Rounded window corners
   - Drop shadows

4. **Icons & Theme**
   - WhiteSur or McMojave icon theme
   - WhiteSur GTK theme
   - WhiteSur Plasma theme
   - San Francisco-style fonts (or Inter/SF Pro alternatives)

5. **File Manager**
   - Dolphin configured with sidebar like Finder
   - Column view option
   - Quick Look preview (Space key)

### Implementation

**Theme Package Contents**:
```
~/.local/share/qalarc-themes/macos/
├── plasma-theme/           # Plasma desktop theme
├── color-scheme/           # Color scheme files
├── window-decoration/      # Window button positions
├── latte-dock-config/      # Dock configuration
├── icons/                  # Icon theme
├── fonts/                  # Font configuration
├── konsole-profile/        # Terminal theme
├── dolphin-config/         # File manager layout
└── apply-theme.sh          # One-click apply script
```

**KDE Components to Configure**:
```nix
# In NixOS configuration
environment.systemPackages = with pkgs; [
  # Theme packages
  whitesur-gtk-theme
  whitesur-icon-theme

  # Dock
  latte-dock

  # Fonts (macOS-like)
  inter
  roboto

  # Tools
  kvantum              # Advanced theme engine
  plasma5Packages.lightly  # Window decoration
];

# Plasma settings
programs.plasma = {
  enable = true;
  overrideConfig = true;

  # Global menu
  panels = [{
    location = "top";
    height = 28;
    widgets = [
      "org.kde.plasma.appmenu"
      "org.kde.plasma.panelspacer"
      "org.kde.plasma.digitalclock"
      "org.kde.plasma.panelspacer"
      "org.kde.plasma.systemtray"
    ];
  }];
};
```

### Apply Command

```bash
# Apply macOS theme preset
qalarc-theme apply macos

# Preview theme before applying
qalarc-theme preview macos

# Revert to default qalarc theme
qalarc-theme apply default

# List available themes
qalarc-theme list
```

### Additional Presets (Future)

1. **macOS Light** - Light mode version
2. **macOS Dark** - Dark mode (default)
3. **Windows 11** - Windows-style layout
4. **Ubuntu** - Ubuntu/GNOME style
5. **qalarc Default** - Custom Catppuccin-based theme

### Benefits

- ✅ Familiar interface for macOS users
- ✅ Easier transition from macOS to Linux
- ✅ Professional appearance
- ✅ One-click application
- ✅ Easy to revert

### References

- WhiteSur Theme: https://github.com/vinceliuice/WhiteSur-gtk-theme
- McMojave Theme: https://github.com/vinceliuice/McMojave-kde
- Latte Dock: https://github.com/KDE/latte-dock
- Global Menu: KDE Plasma built-in

---

**Last Updated**: 2025-11-18
**Status**: Planning / Research
**Next Review**: Phase 8 completion + 2 weeks

**References**:
- D2F Paper: https://github.com/zhijie-group/Discrete-Diffusion-Forcing
- Whisper: https://github.com/openai/whisper
- Piper TTS: https://github.com/rhasspy/piper
- PyGaze: http://www.pygaze.org/
- WhiteSur Theme: https://github.com/vinceliuice/WhiteSur-gtk-theme
