# Qalarc AI-OS Project Status
**Last Updated**: January 8, 2025

---

## PROJECT VISION

**Qalarc AI-OS** is a complete, turnkey operating system for 128GB+ mini PCs (GMKTEC EVO-X2, Minisforum, Framework) that provides:

1. **Pre-configured AI infrastructure** - Ollama, llama.cpp, ROCm ready
2. **16TB offline knowledge base** - Wikipedia, PubMed, arXiv, StackOverflow, legal databases
3. **Claude Code-like experience** - OpenCode + local models in TMUX
4. **Enterprise features** - Multi-user, API gateway, compliance modules
5. **Best-in-class UX** - Welcome wizard, guided setup, everything explained

---

## CURRENT STATUS: PHASE 1 (Foundation)

### What EXISTS Now (in qalarc_OS repo)

| Component | Status | Location |
|-----------|--------|----------|
| NixOS base configuration | ✅ Complete | `hosts/gmktec-01/` |
| KDE Plasma 6 desktop | ✅ Complete | `modules/desktop/` |
| Basic AI/ML module | ⚠️ Minimal | `modules/ai-ml/` |
| Development tools | ✅ Complete | `modules/development/` |
| Media tools | ✅ Complete | `modules/media/` |
| Networking (Tailscale, SSH) | ✅ Complete | `modules/networking/` |
| BTRFS snapshots | ✅ Complete | `modules/snapper/` |
| System monitoring | ✅ Complete | `modules/system-monitor/` |
| Branding/wallpapers | ✅ Complete | `modules/branding/` |
| Welcome wizard (basic) | ⚠️ Basic | `modules/branding/` |

### What NEEDS to be Built

| Component | Priority | Status |
|-----------|----------|--------|
| Interactive setup wizard | 🔴 HIGH | ❌ Not started |
| Software installation selector | 🔴 HIGH | ❌ Not started |
| OpenCode installation | 🔴 HIGH | ❌ Not started |
| Claude Code installation | 🔴 HIGH | ❌ Not started |
| TMUX configuration (match your setup) | 🔴 HIGH | ❌ Not started |
| Power+Enter → Ghostty keybind | 🔴 HIGH | ❌ Not started |
| Knowledge base installer | 🟡 MEDIUM | ❌ Not started |
| RAG system | 🟡 MEDIUM | ❌ Not started |
| Web dashboard | 🟡 MEDIUM | ❌ Not started |
| OpenAI-compatible API gateway | 🟡 MEDIUM | ❌ Not started |
| Multi-user isolation | 🟢 LOW | ❌ Not started |
| Healthcare compliance module | 🟢 LOW | ❌ Not started |

---

## FOLDER STRUCTURE

```
qalarc_OS/
├── ROADMAP/                    # THIS FOLDER - Project tracking
│   ├── 00_PROJECT_STATUS.md    # Where we are now
│   ├── 01_COMPLETE_FEATURE_LIST.md
│   ├── 02_SOFTWARE_CATALOG.md  # All apps with sizes/reasons
│   ├── 03_KNOWLEDGE_BASES.md   # 16TB context system
│   ├── 04_SETUP_WIZARD_SPEC.md # Interactive installer design
│   └── 05_FUTURE_ROADMAP.md    # Long-term vision
├── hosts/                      # Machine-specific configs
├── modules/                    # NixOS modules
├── scripts/                    # Helper scripts
├── wallpapers/                 # Branding assets
└── docs/                       # User documentation
```

---

## IMMEDIATE TASKS (This Session)

- [x] Create ROADMAP folder
- [ ] Document complete software catalog with sizes
- [ ] Design interactive setup wizard
- [ ] Add OpenCode to installation
- [ ] Add Claude Code to installation
- [ ] Configure TMUX to match your setup
- [ ] Set Power+Enter → Ghostty keybind
- [ ] Create `qalarc-explain` program

---

## KEY DECISIONS MADE

1. **Software-first approach** - We make the OS, users bring compatible hardware
2. **NixOS base** - Reproducibility over raw performance
3. **KDE Plasma** - Windows-familiar with tiling option
4. **Ollama primary** - Easy model management, llama.cpp for power users
5. **BTRFS** - Snapshots critical for experimentation

---

## REFERENCE DOCUMENTS

| Document | Location | Purpose |
|----------|----------|---------|
| Critical Features | `Local_infrastructure/instances/_shared/dev-team/CRITICAL_FEATURES_LIST.md` | Customer requirements |
| Feature Roadmap | `Local_infrastructure/instances/09_feature_development/outputs/09_feature_roadmap_20250905.md` | Development plan |
| Knowledge Base | `Local_infrastructure/instances/10_qa_testing/outputs/10_knowledge_base_status_20250905.md` | 16TB context system |
| Architecture | `Local_infrastructure/instances/08_system_architecture/outputs/08_architecture_design_20250905.md` | System design |
| AI Engines | `Local_infrastructure/instances/08_system_architecture/outputs/08_ai_engines_evaluation_20250905.md` | Inference options |

---

## CONTACT

- Website: qalarc.com
- Email: team@qalarc.com
