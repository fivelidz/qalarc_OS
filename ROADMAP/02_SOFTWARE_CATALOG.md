# Qalarc AI-OS Software Catalog
**Complete list of pre-installed and optional software**

---

## LEGEND

- **PRE-INSTALLED**: Comes with base system
- **RECOMMENDED**: Suggested during setup wizard
- **OPTIONAL**: User chooses during setup
- **FUTURE**: Planned but not yet available

---

## CATEGORY 1: AI/ML CORE

### Pre-Installed

| Software | Size | Description | Why Included |
|----------|------|-------------|--------------|
| **Ollama** | ~500MB | LLM server with model management | Easiest way to run local models, OpenAI-compatible API |
| **ROCm Tools** | ~2GB | AMD GPU compute stack | Required for GPU acceleration on AMD systems |
| **Python 3.12** | ~100MB | Programming language | Foundation for ML/AI development |

### Recommended (Setup Wizard)

| Software | Size | Description | Why Recommended |
|----------|------|-------------|-----------------|
| **llama.cpp** | ~50MB | High-performance CPU inference | 10-15% faster than Ollama for power users |
| **PyTorch (ROCm)** | ~5GB | Deep learning framework | For custom model training and inference |
| **Transformers** | ~500MB | Hugging Face library | Access to thousands of models |

### Optional

| Software | Size | Description | Why Optional |
|----------|------|-------------|--------------|
| **vLLM** | ~2GB | Production serving | Only needed for high-concurrency deployments |
| **text-generation-webui** | ~1GB | Feature-rich web UI | For users who prefer GUI over terminal |
| **ComfyUI** | ~2GB | Image generation UI | Only for image generation workflows |

---

## CATEGORY 2: AI CODING ASSISTANTS

### Pre-Installed

| Software | Size | Description | Why Included |
|----------|------|-------------|--------------|
| **Claude Code** | ~100MB | Anthropic's CLI for Claude | Primary AI coding assistant |
| **OpenCode** | ~50MB | Open-source Claude Code alternative | Works with local models |

### Recommended

| Software | Size | Description | Why Recommended |
|----------|------|-------------|-----------------|
| **codecompanion.nvim** | ~5MB | Neovim AI plugin | Best Neovim AI integration |
| **llama.vim** | ~2MB | Vim AI completions | 100% local, no API needed |
| **avante.nvim** | ~5MB | Cursor-like Neovim | Agentic file operations |

---

## CATEGORY 3: DEVELOPMENT TOOLS

### Pre-Installed

| Software | Size | Description | Why Included |
|----------|------|-------------|--------------|
| **VS Code** | ~300MB | GUI code editor | Most popular editor, extension ecosystem |
| **Neovim** | ~50MB | Terminal editor | Power user editing, AI plugin support |
| **Vim** | ~30MB | Classic editor | Universal availability |
| **Git** | ~50MB | Version control | Essential for all development |
| **GitHub CLI** | ~30MB | GitHub from terminal | PR, issues, repos from CLI |
| **Lazygit** | ~20MB | Git TUI | Visual git without leaving terminal |
| **Ghostty** | ~20MB | Modern terminal | Fast, GPU-accelerated, beautiful |
| **TMUX** | ~5MB | Terminal multiplexer | Session management, split panes |

### Pre-Installed Languages

| Language | Size | Description |
|----------|------|-------------|
| **Python 3.12** | ~100MB | ML/AI, scripting, automation |
| **Node.js 22** | ~100MB | JavaScript runtime, web development |
| **Rust** | ~500MB | Systems programming, performance |
| **Go** | ~200MB | Backend services, CLI tools |

### Pre-Installed Utilities

| Tool | Size | Description |
|------|------|-------------|
| **jq** | ~2MB | JSON processor (critical for AI scripts) |
| **ripgrep** | ~5MB | Fast code search |
| **fd** | ~3MB | Fast file finder |
| **bat** | ~5MB | Better cat with syntax highlighting |
| **fzf** | ~3MB | Fuzzy finder |
| **direnv** | ~5MB | Environment management |
| **tldr** | ~10MB | Simplified man pages |

### Recommended

| Software | Size | Description | Why Recommended |
|----------|------|-------------|-----------------|
| **Docker** | ~500MB | Containerization | Isolate AI workloads |
| **Podman** | ~100MB | Docker alternative | Rootless containers |

---

## CATEGORY 4: DESKTOP ENVIRONMENT

### Pre-Installed

| Software | Size | Description | Why Included |
|----------|------|-------------|--------------|
| **KDE Plasma 6** | ~1GB | Desktop environment | Windows-familiar, highly customizable |
| **Krohnkite** | ~5MB | Tiling extension | Vim-style window management |
| **Dolphin** | ~50MB | File manager | KDE native, powerful |
| **Konsole** | ~30MB | KDE terminal | Backup terminal |
| **Kate** | ~50MB | Advanced text editor | GUI text editing |
| **Spectacle** | ~20MB | Screenshot tool | Screen capture |
| **KDE Connect** | ~30MB | Phone integration | Sync with mobile devices |

---

## CATEGORY 5: MEDIA & CONTENT

### Pre-Installed

| Software | Size | Description | Why Included |
|----------|------|-------------|--------------|
| **Brave** | ~200MB | Privacy browser | Default web browser |
| **Firefox** | ~200MB | Backup browser | Compatibility fallback |
| **VLC** | ~100MB | Media player | Plays everything |
| **MPV** | ~50MB | Lightweight player | Minimal, scriptable |
| **FFmpeg** | ~100MB | Media conversion | Foundation for all media tools |

### Recommended

| Software | Size | Description | Why Recommended |
|----------|------|-------------|-----------------|
| **OBS Studio** | ~200MB | Recording/streaming | Screen recording, tutorials |
| **GIMP** | ~100MB | Image editing | Photo manipulation |
| **Kdenlive** | ~200MB | Video editing | Video production |

### Optional

| Software | Size | Description | Why Optional |
|----------|------|-------------|--------------|
| **Google Chrome** | ~300MB | Chrome browser | If Brave doesn't work for something |
| **Inkscape** | ~100MB | Vector graphics | Only for design work |
| **Krita** | ~200MB | Digital painting | Only for artists |
| **Handbrake** | ~50MB | Video transcoding | Batch video conversion |

---

## CATEGORY 6: NETWORKING & REMOTE ACCESS

### Pre-Installed

| Software | Size | Description | Why Included |
|----------|------|-------------|--------------|
| **Tailscale** | ~30MB | Zero-config VPN | Easy remote access from anywhere |
| **OpenSSH** | ~10MB | SSH server/client | Remote terminal access |
| **Avahi** | ~5MB | Local discovery | Find devices on LAN |

### Recommended

| Software | Size | Description | Why Recommended |
|----------|------|-------------|-----------------|
| **Sunshine** | ~50MB | Desktop streaming | Stream to Moonlight clients |
| **WireGuard** | ~5MB | VPN protocol | Self-hosted VPN option |

---

## CATEGORY 7: SYSTEM TOOLS

### Pre-Installed

| Software | Size | Description | Why Included |
|----------|------|-------------|--------------|
| **btop** | ~5MB | System monitor | Beautiful resource monitoring |
| **htop** | ~2MB | Process viewer | Classic system monitoring |
| **nvtop** | ~5MB | GPU monitor | AMD GPU usage tracking |
| **Conky** | ~5MB | Desktop overlay | Always-visible system stats |
| **Snapper** | ~5MB | Snapshot manager | BTRFS snapshot automation |

---

## CATEGORY 8: AI MODELS (Downloaded Separately)

### Recommended First Models

| Model | Size | Speed (128GB system) | Best For |
|-------|------|---------------------|----------|
| **Qwen2.5:7B** | ~4GB | 80-100 tok/s | Quick responses, testing |
| **Qwen2.5-Coder:32B** | ~18GB | 30-40 tok/s | Code generation (RECOMMENDED) |
| **Llama 3.3:70B Q4** | ~38GB | 25-30 tok/s | General purpose, reasoning |

### Large Models (128GB+ systems)

| Model | Size | Speed | Best For |
|-------|------|-------|----------|
| **Llama 3.1:405B Q3** | ~210GB | 8-10 tok/s | Maximum quality (uses mmap) |
| **DeepSeek-Coder:33B** | ~18GB | 30-40 tok/s | Code with fill-in-middle |

---

## CATEGORY 9: KNOWLEDGE BASES (Optional Download)

### Available Knowledge Packs

| Pack | Size | Contents |
|------|------|----------|
| **Wikipedia Offline** | 600GB | 6.2M articles, searchable |
| **Technical Docs** | 2TB | GitHub, StackOverflow, APIs |
| **Scientific Papers** | 3TB | arXiv, open journals |
| **Medical Knowledge** | 2TB | PubMed, drug DBs, ICD-10 |
| **Legal Database** | 1TB | US case law, statutes |

---

## TOTAL SIZES

| Installation Type | Size | Description |
|-------------------|------|-------------|
| **Minimal** | ~15GB | OS + essential tools only |
| **Standard** | ~25GB | + recommended apps |
| **Full** | ~40GB | + all optional apps |
| **With Models** | ~100-250GB | + AI models |
| **With Knowledge** | ~8-16TB | + offline knowledge bases |

---

## SETUP WIZARD FLOW

1. **Essential** (auto-installed): OS, KDE, basic tools
2. **AI Stack** (recommended): Ollama, Claude Code, OpenCode
3. **Development** (choose): Languages, editors, containers
4. **Media** (choose): Browsers, players, editors
5. **Models** (download): Select based on hardware
6. **Knowledge** (optional): Offline databases

Each category shows:
- What it is
- Why you might want it
- Disk space required
- Installation time estimate
