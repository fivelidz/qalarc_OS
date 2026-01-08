# Qalarc AI-OS Complete Feature List
**Everything the system should do**

---

## TIER 1: CORE EXPERIENCE (Must Ship)

### 1.1 First-Boot Experience
- [ ] Welcome wizard with system info display
- [ ] Hardware verification (RAM, VRAM, storage)
- [ ] Interactive software selection with sizes/reasons
- [ ] Model download assistant
- [ ] Keybinding tutorial
- [ ] `qalarc-explain` command for help anytime

### 1.2 AI Coding Environment
- [ ] **Claude Code** pre-installed and configured
- [ ] **OpenCode** pre-installed (same config as your system)
- [ ] TMUX configuration matching your setup
- [ ] Ghostty as default terminal
- [ ] **Power+Enter** opens Ghostty
- [ ] AI workspace launcher (`qalarc-ai-workspace`)

### 1.3 Local LLM Infrastructure
- [ ] Ollama with ROCm acceleration
- [ ] Pre-configured for 96GB VRAM
- [ ] Model management commands
- [ ] OpenAI-compatible API on localhost:11434
- [ ] Performance monitoring

### 1.4 Desktop Experience
- [ ] KDE Plasma 6 with sensible defaults
- [ ] Krohnkite tiling (vim-style: Meta+J/K/H/L)
- [ ] Qalarc wallpapers
- [ ] Conky system overlay (UMA stats, GPU, AI services)
- [ ] Dark theme by default

### 1.5 System Safety
- [ ] BTRFS snapshots before every update
- [ ] Boot into any snapshot from GRUB
- [ ] Manual snapshot shortcut (Super+Shift+S)
- [ ] Snapshot browser/manager

---

## TIER 2: PRODUCTIVITY (High Value)

### 2.1 Development Tools
- [ ] VS Code with AI extensions pre-configured
- [ ] Neovim with codecompanion.nvim, llama.vim
- [ ] Full language support (Python, Rust, Node, Go)
- [ ] Docker/Podman ready
- [ ] Git with Lazygit TUI

### 2.2 Remote Access
- [ ] Tailscale zero-config VPN
- [ ] SSH with key management
- [ ] Sunshine streaming (Moonlight compatible)
- [ ] Access Ollama API from phone

### 2.3 Media Tools
- [ ] FFmpeg with all codecs
- [ ] `qalarc-convert` helper script
- [ ] VLC, MPV for playback
- [ ] OBS for recording

---

## TIER 3: KNOWLEDGE SYSTEM (Differentiator)

### 3.1 Offline Knowledge Bases
- [ ] Wikipedia offline (600GB)
- [ ] Technical documentation (2TB)
- [ ] Scientific papers (3TB)
- [ ] Medical knowledge (2TB)
- [ ] Legal databases (1TB)

### 3.2 RAG System
- [ ] Document ingestion (PDF, DOCX, TXT)
- [ ] Vector search with ChromaDB
- [ ] Semantic search across all sources
- [ ] Citation generation
- [ ] <100ms retrieval time

### 3.3 Knowledge Management
- [ ] Add custom documents
- [ ] Organization-specific knowledge
- [ ] Update scheduling
- [ ] Storage optimization

---

## TIER 4: ENTERPRISE (Future)

### 4.1 Multi-User
- [ ] User isolation
- [ ] Resource quotas
- [ ] Usage tracking
- [ ] LDAP/AD integration

### 4.2 API Gateway
- [ ] Full OpenAI compatibility
- [ ] Rate limiting
- [ ] API key management
- [ ] Request logging

### 4.3 Compliance
- [ ] HIPAA module (healthcare)
- [ ] Audit logging
- [ ] Data encryption
- [ ] Air-gap operation

### 4.4 Web Dashboard
- [ ] Model management UI
- [ ] Chat playground
- [ ] Usage analytics
- [ ] System monitoring

---

## KEYBINDINGS (Pre-Configured)

| Keybinding | Action |
|------------|--------|
| **Power + Enter** | Open Ghostty terminal |
| **Meta + T** | Toggle tiling mode |
| **Meta + J/K/H/L** | Navigate windows (vim-style) |
| **Meta + Shift + J/K/H/L** | Move windows |
| **Super + Shift + S** | Create snapshot |
| **Meta + Return** | Open terminal (alternative) |

---

## COMMANDS (Pre-Installed)

| Command | Description |
|---------|-------------|
| `qalarc-welcome` | Show welcome wizard |
| `qalarc-explain` | Interactive help system |
| `qalarc-ai-workspace` | Launch AI coding environment |
| `qalarc-set-wallpaper` | Choose wallpaper |
| `qalarc-system-info` | Show system details |
| `qalarc-convert` | Media conversion helper |
| `qalarc-snapshot` | Create manual snapshot |
| `ollama list` | Show downloaded models |
| `ollama run <model>` | Start chatting with model |

---

## MODELS (Recommended Downloads)

### For 128GB Systems (Quad-Channel)

| Model | Command | Size | Use Case |
|-------|---------|------|----------|
| Qwen2.5-Coder 32B | `ollama pull qwen2.5-coder:32b` | 18GB | Code generation |
| Llama 3.3 70B | `ollama pull llama3.3:70b` | 38GB | General purpose |
| DeepSeek-Coder | `ollama pull deepseek-coder:33b` | 18GB | Code with FIM |

### For Testing (Any System)

| Model | Command | Size | Use Case |
|-------|---------|------|----------|
| Qwen2.5 7B | `ollama pull qwen2.5:7b` | 4GB | Quick testing |
| Mistral 7B | `ollama pull mistral:7b` | 4GB | Fast responses |

---

## SUCCESS CRITERIA

### User can...
- [ ] Boot to working system in < 2 minutes
- [ ] Launch AI workspace in < 5 seconds
- [ ] Start chatting with AI in < 30 seconds
- [ ] Open terminal with Power+Enter
- [ ] Understand what's installed via `qalarc-explain`
- [ ] Recover from any mistake via snapshots
- [ ] Access system remotely via Tailscale
- [ ] Run 70B models at 25+ tokens/sec

### System provides...
- [ ] List of all installed software
- [ ] Explanation for why each tool is included
- [ ] Size of each component
- [ ] Easy way to add/remove optional software
- [ ] Matching TMUX config to developer's machine
- [ ] Claude Code and OpenCode ready to use
