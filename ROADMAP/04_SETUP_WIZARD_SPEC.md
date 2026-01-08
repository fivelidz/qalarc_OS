# Qalarc AI-OS Setup Wizard Specification
**Interactive first-boot experience**

---

## OVERVIEW

The setup wizard (`qalarc-setup`) runs on first boot and guides users through:
1. System verification
2. Software selection with explanations
3. Model downloads
4. Keybinding tutorial
5. Final configuration

---

## SCREEN 1: WELCOME

```
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║   ██████╗  █████╗ ██╗      █████╗ ██████╗  ██████╗              ║
║  ██╔═══██╗██╔══██╗██║     ██╔══██╗██╔══██╗██╔════╝              ║
║  ██║   ██║███████║██║     ███████║██████╔╝██║                   ║
║  ██║▄▄ ██║██╔══██║██║     ██╔══██║██╔══██╗██║                   ║
║  ╚██████╔╝██║  ██║███████╗██║  ██║██║  ██║╚██████╗              ║
║   ╚══▀▀═╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝              ║
║                                                                  ║
║                         A I - O S                                ║
║                                                                  ║
║  Welcome to Qalarc AI-OS!                                        ║
║                                                                  ║
║  This wizard will help you:                                      ║
║    1. Verify your hardware is configured correctly               ║
║    2. Choose which software to install                           ║
║    3. Download AI models for your system                         ║
║    4. Learn the essential keyboard shortcuts                     ║
║                                                                  ║
║  Estimated time: 10-30 minutes (depending on downloads)          ║
║                                                                  ║
║  Press [ENTER] to continue or [Q] to skip setup                  ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## SCREEN 2: HARDWARE VERIFICATION

```
╔══════════════════════════════════════════════════════════════════╗
║  HARDWARE VERIFICATION                                           ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Checking your system...                                         ║
║                                                                  ║
║  CPU:     AMD Ryzen AI Max+ 395 (16 cores)           ✓ OPTIMAL  ║
║  RAM:     128GB LPDDR5X-8000                         ✓ OPTIMAL  ║
║  GPU:     AMD Radeon 8060S (40 CUs)                  ✓ DETECTED ║
║  VRAM:    96GB UMA allocated                         ✓ OPTIMAL  ║
║  Storage: 2TB NVMe (1.8TB free)                      ✓ GOOD     ║
║                                                                  ║
║  ────────────────────────────────────────────────────────────── ║
║                                                                  ║
║  RECOMMENDATION: Your system can run:                            ║
║    • Multiple 70B models simultaneously                          ║
║    • Llama 405B with mmap                                        ║
║    • Full development environment                                ║
║                                                                  ║
║  ⚠️  Note: If VRAM shows less than 96GB, reboot into BIOS and   ║
║      set Graphics Memory to 96GB under Advanced > Graphics.      ║
║                                                                  ║
║  [ENTER] Continue    [R] Recheck    [?] Help                     ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## SCREEN 3: SOFTWARE CATEGORIES

```
╔══════════════════════════════════════════════════════════════════╗
║  SOFTWARE INSTALLATION                                           ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Select categories to configure:                                 ║
║                                                                  ║
║  [1] AI/ML Stack ................ Required .......... ~8GB      ║
║      Ollama, Claude Code, OpenCode, PyTorch                      ║
║                                                                  ║
║  [2] Development Tools .......... Recommended ....... ~2GB      ║
║      VS Code, Neovim, Git, Languages                             ║
║                                                                  ║
║  [3] Media & Browsers ........... Recommended ....... ~1GB      ║
║      Brave, Firefox, VLC, FFmpeg                                 ║
║                                                                  ║
║  [4] AI Models .................. Choose models ..... 4-200GB   ║
║      Download models for local inference                         ║
║                                                                  ║
║  [5] Knowledge Bases ............ Optional .......... 1-16TB    ║
║      Offline Wikipedia, StackOverflow, PubMed                    ║
║                                                                  ║
║  [A] Install All Recommended                                     ║
║  [M] Minimal Installation                                        ║
║  [C] Custom Selection                                            ║
║                                                                  ║
║  Enter selection: _                                              ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## SCREEN 4: AI/ML STACK DETAIL

```
╔══════════════════════════════════════════════════════════════════╗
║  AI/ML STACK                                                     ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  INCLUDED (Required):                                            ║
║  ┌────────────────────────────────────────────────────────────┐ ║
║  │ Ollama                                           500MB     │ ║
║  │ Local LLM server with easy model management                │ ║
║  │ WHY: Simplest way to run AI models locally                 │ ║
║  ├────────────────────────────────────────────────────────────┤ ║
║  │ Claude Code                                      100MB     │ ║
║  │ Anthropic's AI coding assistant CLI                        │ ║
║  │ WHY: Best-in-class AI pair programming                     │ ║
║  ├────────────────────────────────────────────────────────────┤ ║
║  │ OpenCode                                         50MB      │ ║
║  │ Open-source Claude Code alternative                        │ ║
║  │ WHY: Works with local models, same interface               │ ║
║  ├────────────────────────────────────────────────────────────┤ ║
║  │ ROCm Tools                                       2GB       │ ║
║  │ AMD GPU compute drivers                                    │ ║
║  │ WHY: Required for GPU-accelerated inference                │ ║
║  └────────────────────────────────────────────────────────────┘ ║
║                                                                  ║
║  OPTIONAL:                                                       ║
║  [ ] PyTorch + ROCm ............................ 5GB            ║
║      Deep learning framework for custom models                   ║
║  [ ] llama.cpp ................................. 50MB           ║
║      High-performance inference (10% faster)                     ║
║  [ ] text-generation-webui ..................... 1GB            ║
║      Web-based chat interface                                    ║
║                                                                  ║
║  [ENTER] Continue    [SPACE] Toggle selection    [?] More info   ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## SCREEN 5: MODEL SELECTION

```
╔══════════════════════════════════════════════════════════════════╗
║  AI MODEL SELECTION                                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Your system (128GB RAM) can run these models:                   ║
║                                                                  ║
║  RECOMMENDED FOR YOU:                                            ║
║  [*] Qwen2.5-Coder:32B ................. 18GB ... 30-40 tok/s   ║
║      Best for code generation and programming help               ║
║                                                                  ║
║  [*] Llama 3.3:70B Q4 .................. 38GB ... 25-30 tok/s   ║
║      Best general-purpose model for reasoning                    ║
║                                                                  ║
║  SMALLER (Fast responses):                                       ║
║  [ ] Qwen2.5:7B ........................ 4GB .... 80-100 tok/s  ║
║  [ ] Mistral:7B ........................ 4GB .... 80-100 tok/s  ║
║                                                                  ║
║  LARGER (Maximum quality):                                       ║
║  [ ] Llama 3.1:405B Q3 ................. 210GB .. 8-10 tok/s    ║
║      Note: Requires mmap, slower but highest quality             ║
║                                                                  ║
║  SPECIALIZED:                                                    ║
║  [ ] DeepSeek-Coder:33B ................ 18GB ... 30-40 tok/s   ║
║      Fill-in-the-middle code completion                          ║
║                                                                  ║
║  Selected: 56GB total                                            ║
║                                                                  ║
║  [ENTER] Download selected    [N] Skip for now    [?] Help       ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## SCREEN 6: KEYBINDING TUTORIAL

```
╔══════════════════════════════════════════════════════════════════╗
║  KEYBOARD SHORTCUTS                                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  ESSENTIAL SHORTCUTS (memorize these!):                          ║
║                                                                  ║
║  ┌─────────────────────┬───────────────────────────────────────┐ ║
║  │ Power + Enter       │ Open Ghostty terminal                 │ ║
║  │ Meta + Return       │ Open terminal (alternative)           │ ║
║  │ Super + Shift + S   │ Create system snapshot                │ ║
║  └─────────────────────┴───────────────────────────────────────┘ ║
║                                                                  ║
║  WINDOW MANAGEMENT (vim-style tiling):                           ║
║  ┌─────────────────────┬───────────────────────────────────────┐ ║
║  │ Meta + T            │ Toggle tiling mode                    │ ║
║  │ Meta + J/K/H/L      │ Move focus down/up/left/right         │ ║
║  │ Meta + Shift + ↑    │ Move window in direction              │ ║
║  └─────────────────────┴───────────────────────────────────────┘ ║
║                                                                  ║
║  AI COMMANDS:                                                    ║
║  ┌─────────────────────┬───────────────────────────────────────┐ ║
║  │ qalarc-ai-workspace │ Launch AI coding environment          │ ║
║  │ ollama run <model>  │ Chat with a model                     │ ║
║  │ claude              │ Start Claude Code                     │ ║
║  │ opencode            │ Start OpenCode                        │ ║
║  └─────────────────────┴───────────────────────────────────────┘ ║
║                                                                  ║
║  TIP: Run 'qalarc-explain' anytime to see all commands           ║
║                                                                  ║
║  [ENTER] Continue    [P] Practice mode    [?] Full list          ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## SCREEN 7: COMPLETE

```
╔══════════════════════════════════════════════════════════════════╗
║  SETUP COMPLETE!                                                 ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  ✓ Hardware verified                                             ║
║  ✓ Software installed                                            ║
║  ✓ Models downloaded (2 of 2)                                    ║
║  ✓ Keyboard shortcuts configured                                 ║
║  ✓ Initial snapshot created                                      ║
║                                                                  ║
║  ────────────────────────────────────────────────────────────── ║
║                                                                  ║
║  QUICK START:                                                    ║
║                                                                  ║
║    1. Press Power+Enter to open terminal                         ║
║    2. Type: ollama run qwen2.5-coder:32b                         ║
║    3. Start coding with AI!                                      ║
║                                                                  ║
║  Or launch the full AI workspace:                                ║
║    qalarc-ai-workspace                                           ║
║                                                                  ║
║  Need help anytime?                                              ║
║    qalarc-explain                                                ║
║                                                                  ║
║  ────────────────────────────────────────────────────────────── ║
║                                                                  ║
║  [ENTER] Start using Qalarc AI-OS                                ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## IMPLEMENTATION NOTES

### Technology
- Written in Bash or Python
- Uses `dialog` or `whiptail` for TUI
- Can also be implemented in Rust with `ratatui`
- Saves selections to `/etc/qalarc/setup-state.json`

### Behavior
- Runs on first boot automatically
- Can be re-run with `qalarc-setup`
- Skippable with `Q` at any point
- Progress saved if interrupted

### Integration
- Triggers nixos-rebuild for software changes
- Uses ollama pull for model downloads
- Creates snapshot at completion
