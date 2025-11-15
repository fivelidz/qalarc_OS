# qalarc_OS Design Decisions

This document tracks major architectural decisions with their rationale, alternatives considered, and outcomes. Format is optimized for LLM comprehension.

---

## Decision Log

### 1. Operating System: NixOS vs CachyOS

**Date:** 2025-11-15
**Status:** ✅ Decided - NixOS with optimizations

**Context:**
Need a reproducible deployment system for multiple GMKTEC EVO-X2 AI systems with AMD Ryzen AI Max+ 395. Must balance performance for AI workloads with reproducibility across deployments.

**Decision:**
Use **NixOS 25.05** with CachyOS kernel and architecture-specific optimizations for critical packages.

**Rationale:**
1. **Reproducibility is critical** - Deploy to multiple machines with identical configuration
2. **CachyOS kernel is available on NixOS** via Chaotic-Nyx (confirmed in research)
3. **Performance gap can be mitigated:**
   - Use CachyOS kernel (BORE scheduler, x86-64-v3 optimizations)
   - Compile critical AI packages with `-march=native -O3`
   - Use MKL-optimized BLAS/LAPACK
   - ROCm with architecture-specific builds

4. **nixified.ai** provides foundation for AI stack on Nix

**Alternatives Considered:**

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **Pure CachyOS** | Best raw performance (10-30% faster for some workloads), x86-64-v4 binaries | Poor reproducibility (~70% vs 100%), harder multi-machine deployment, no declarative config | ❌ Rejected |
| **CachyOS + Docker** | Performance + some reproducibility | More complex (two systems), not truly declarative, Docker overhead | ❌ Rejected |
| **NixOS (generic)** | Perfect reproducibility, simple | 10-30% slower for CPU-bound ML inference | ❌ Too slow |
| **NixOS + optimizations** | Good reproducibility, acceptable performance | Longer build times for optimized packages | ✅ **SELECTED** |

**Benchmarks Required:**
- [ ] llama.cpp inference (tokens/sec with 70B model)
- [ ] PyTorch matmul performance (TFLOPS)
- [ ] System responsiveness (scheduler latency)

**Success Criteria:**
NixOS optimized performance within **10% of CachyOS** for LLM inference workloads.

**References:**
- NixOS Discourse: x86-64-v3 transition RFC
- Chaotic-Nyx CachyOS kernel availability

---

### 2. Desktop Environment: KDE Plasma 6 vs Hyprland

**Date:** 2025-11-15
**Status:** ✅ Decided - KDE Plasma 6 with Krohnkite tiling

**Context:**
Need a desktop environment that is:
- Customizable for future AI integration
- Easy to use for people familiar with Windows
- Suitable as default interface for AI assistants (Ghostty/TMUX)

**Decision:**
**KDE Plasma 6** with **Krohnkite** tiling extension.

**Rationale:**
1. **Windows familiarity** - Taskbar, system tray, start menu (critical requirement)
2. **Tiling available** - Krohnkite provides vim-style tiling without losing GUI
3. **AI integration possible** - D-Bus scripting, KWin scripts (JavaScript)
4. **Point-and-click config** - No text config files for basic use
5. **Better compatibility** - More applications work out-of-box with KDE

**User Input:**
> "I think KDE plasma with tiling shortcuts may be the best of both worlds. More compatible with existing systems"

This validated the decision toward KDE over Hyprland.

**Alternatives Considered:**

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **Hyprland** | Beautiful animations, socket-based IPC for AI control, highly customizable | Steep learning curve, NOT Windows-like, requires text config, Wayland-only | ❌ Rejected |
| **Hyprland + waybar** | Can create taskbar/tray/menu | Still requires config files, not intuitive for Windows users | ❌ Rejected |
| **KDE Plasma 6 (basic)** | Easy to use, Windows-familiar | No tiling | ⚠️ Incomplete |
| **KDE + Krohnkite** | Tiling + GUI + Windows-like + AI scriptable | Slightly less elegant than Hyprland | ✅ **SELECTED** |

**Tiling Configuration:**
- Krohnkite KWin script (ported to Plasma 6)
- Vim-style navigation: `Meta+J/K/H/L`
- Toggle tiling: `Meta+T`
- Manual snapshot: `Super+Shift+S`

**AI Integration Notes:**
- D-Bus can control windows programmatically
- KWin scripts for custom window management logic
- Conky overlay for system stats (GPU, UMA, AI services)

---

### 3. Filesystem: BTRFS with Subvolumes

**Date:** 2025-11-15
**Status:** ✅ Decided - BTRFS with specific subvolume layout

**Context:**
Need a filesystem that supports snapshots, is NAS-friendly, and can handle AI workloads efficiently.

**Decision:**
**BTRFS** with the following subvolume structure:

```
@           → /              (root - snapshotted, compress=zstd:3)
@home       → /home          (user files - snapshotted, compress=zstd:3)
@nix        → /nix           (Nix store - NOT snapshotted, no compression)
@local-llms → /local-llms    (AI models - compress=zstd:1, conditional snapshots)
@context    → /context       (code/docs - compress=zstd:3, snapshotted)
@snapshots  → /.snapshots    (Snapper storage)
@var-log    → /var/log       (logs - NOT snapshotted, compress=zstd:3)
```

**Rationale:**
1. **Snapshots** - Roll back any change (critical for testing)
2. **Compression** - Saves space for text-heavy data (code libraries, Wikipedia)
3. **Subvolumes** - Isolate /local-llms and /context for special handling
4. **NAS-friendly** - Works well with NFS/SMB
5. **Self-healing** - Checksums detect corruption

**Compression Strategy:**
- **zstd:3** (default) - Balanced compression for most data
- **zstd:1** (llms) - Minimal compression for large binary models
- **none** (nix) - Nix store already compressed/deduplicated

**Snapshot Strategy:**
- **Snapshot:** /, /home, /context (changes frequently, need recovery)
- **Don't snapshot:** /nix (managed by Nix), /local-llms (large, rarely change)

**Alternatives Considered:**

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **ext4** | Simple, fast, well-tested | No snapshots, no compression, no checksums | ❌ Rejected |
| **ZFS** | Excellent features, reliable | Complex on NixOS, licensing issues, higher memory overhead | ❌ Overkill |
| **XFS** | Good for large files | No snapshots, no compression | ❌ Rejected |
| **BTRFS** | Snapshots, compression, checksums, NixOS-friendly | Past stability issues (now resolved) | ✅ **SELECTED** |

**LUKS Encryption:**
Optional full-disk encryption with clear documentation on what it protects (~10% performance overhead).

---

### 4. Snapshot System: Snapper + GRUB Integration

**Date:** 2025-11-15
**Status:** ✅ Decided - Snapper with grub-btrfs

**Context:**
Need automatic snapshots before system updates, with ability to boot into snapshots for recovery.

**Decision:**
**Snapper** for snapshot management + **grub-btrfs** for boot menu integration.

**Rationale:**
1. **Auto-snapshots before nixos-rebuild** - Safety net for system updates
2. **GRUB menu integration** - Boot into any snapshot without CLI
3. **Retention policy** - Automatic cleanup prevents disk fill
4. **Manual snapshots** - `Super+Shift+S` keyboard shortcut for user control

**Retention Policy:**
```
Hourly:  24 snapshots (1 day)
Daily:   7 snapshots (1 week)
Weekly:  4 snapshots (1 month)
Monthly: 6 snapshots (6 months)
Pre/post updates: 10 snapshots
```

**Estimated Storage:** 20-50GB on 128GB system (acceptable overhead)

**Alternatives Considered:**

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **btrbk** | Simpler, scriptable | Less mature NixOS integration, no GRUB integration | ❌ Rejected |
| **Timeshift** | User-friendly GUI | Not well integrated with NixOS, less flexible | ❌ Rejected |
| **Manual BTRFS snapshots** | Full control | No automation, error-prone | ❌ Too manual |
| **Snapper + grub-btrfs** | Full automation, GRUB boot menu, mature NixOS module | Manual .snapshots directory creation | ✅ **SELECTED** |

**Integration Points:**
- Pre-rebuild hook: Creates snapshot before `nixos-rebuild`
- Post-rebuild hook: Creates snapshot after successful rebuild
- grub-btrfsd daemon: Watches /.snapshots and updates GRUB menu automatically

---

### 5. AI Stack: Ollama + PyTorch with ROCm

**Date:** 2025-11-15
**Status:** ✅ Decided - Ollama primary, PyTorch secondary, nixified.ai reference

**Context:**
Need easy-to-use LLM inference with AMD GPU acceleration (96GB VRAM).

**Decision:**
**Ollama** as primary LLM server, **PyTorch** with ROCm for custom workloads, reference **nixified.ai** but build custom stack.

**Rationale:**
1. **Ollama** - Easiest to use, REST API, model management built-in
2. **ROCm support** - AMD GPU acceleration (confirmed working with gfx1151)
3. **96GB VRAM** - Can run 70B+ models entirely in VRAM
4. **nixified.ai** - Good reference but limited ROCm support, use as template

**ROCm Configuration:**
```nix
# GPU detection
HSA_OVERRIDE_GFX_VERSION = "11.5.1";  # gfx1151 for Radeon 8060S
PYTORCH_ROCM_ARCH = "gfx1151";

# Ollama with ROCm
services.ollama = {
  enable = true;
  acceleration = "rocm";
};
```

**NPU (XDNA2) Support:**
- **Current:** Limited Linux support, llama.cpp/ollama don't support NPU yet
- **Future:** Monitor AMD Ryzen AI software for NPU integration
- **Potential:** Time-to-first-token acceleration once supported

**Alternatives Considered:**

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **llama.cpp only** | Direct control, lightweight | Manual model management, no REST API | ❌ Too manual |
| **text-generation-webui** | Feature-rich GUI | Heavy, slower, less scriptable | ❌ Overkill |
| **Ollama** | Easy, REST API, model management | Less control than llama.cpp | ✅ **PRIMARY** |
| **PyTorch native** | Maximum flexibility | Requires coding for inference | ✅ **SECONDARY** |
| **nixified.ai packages** | Pre-packaged | Limited ROCm support, outdated | ⚠️ **REFERENCE** |

**AI Model Storage:**
- `/local-llms/ollama/` - Ollama models
- `/local-llms/huggingface/` - HF cache
- BTRFS with `compress=zstd:1` (minimal compression for binaries)

---

### 6. Boot Loader: GRUB vs systemd-boot

**Date:** 2025-11-15
**Status:** ✅ Decided - GRUB with snapshot support

**Context:**
Need a bootloader that supports:
- BTRFS snapshot booting (critical for recovery)
- Multi-OS booting (testbed for trying other systems)
- User-friendly interface

**Decision:**
**GRUB** with grub-btrfs integration.

**Rationale:**
1. **Snapshot booting** - grub-btrfs automatically adds snapshot entries to boot menu
2. **Multi-OS support** - Easy to add other operating systems
3. **Familiar interface** - Most users know GRUB
4. **Testbed friendly** - User wants to experiment with different OS configurations

**Performance Impact:**
- Boot delay: ~2-3 seconds
- **No runtime performance penalty** (only affects boot time)
- Worth the trade-off for snapshot recovery

**User Input:**
> "I want to set this up as a testbed to make another deployable NixOS with improvements. A grub loader for different drives is appealing to me to practice loading different systems."

This confirmed GRUB as the right choice for multi-boot experimentation.

**Alternatives Considered:**

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **systemd-boot** | Faster (~1s boot), simpler, NixOS default | Harder snapshot booting, no multi-OS support | ❌ Rejected |
| **rEFInd** | Pretty, multi-OS | No automatic snapshot detection | ❌ Rejected |
| **GRUB** | Snapshot support, multi-OS, familiar | ~2s boot delay | ✅ **SELECTED** |

**Configuration:**
```nix
boot.loader = {
  grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;  # Detect other OSes
  };
};
```

---

### 7. Networking: Tailscale vs WireGuard vs OpenVPN

**Date:** 2025-11-15
**Status:** ✅ Decided - Tailscale primary, WireGuard/OpenVPN available

**Context:**
Need easy remote access from phone and other devices, including LLM API access.

**Decision:**
**Tailscale** as primary VPN solution, with WireGuard and OpenVPN available for advanced use cases.

**Rationale:**
1. **Zero-config** - `sudo tailscale up` and done
2. **Mesh network** - Any device can reach any device (phone→PC, PC→PC)
3. **NAT traversal** - Works from anywhere without port forwarding
4. **Mobile-friendly** - Excellent phone apps
5. **Easy LLM access** - Access Ollama API via Tailscale IP

**User Requirements:**
> "Being able to connect with LAN is important too. Being able to function as a remote server to host language models and control the system remotely from the phone or something is important too."

Tailscale perfectly satisfies this with its mesh networking.

**Alternatives Considered:**

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **Tailscale** | Zero-config, NAT traversal, mobile apps, mesh | Third-party service (open-source client) | ✅ **PRIMARY** |
| **WireGuard** | Fast, modern, fully self-hosted | Requires manual configuration, no NAT traversal | ✅ **AVAILABLE** |
| **OpenVPN** | Broad compatibility, mature | Slower than WireGuard, complex config | ✅ **AVAILABLE** |
| **No VPN** | Simplest | Unsafe for remote access | ❌ Rejected |

**LLM Remote Access Example:**
```bash
# On phone (with Tailscale):
curl http://100.64.x.y:11434/api/generate -d '{
  "model": "qwen2.5-coder:32b",
  "prompt": "Write a Python function to..."
}'
```

---

### 8. AI Coding Interface: TMUX + Qwen vs VS Code Extension

**Date:** 2025-11-15
**Status:** ✅ Decided - TMUX workspace with Qwen (Claude Code-like)

**Context:**
User wants an interface similar to Claude Code for working with local AI models.

**Decision:**
Custom **TMUX workspace** (`qalarc-ai-workspace.sh`) with:
- Main pane: Ollama chat with Qwen/local model
- System monitor pane: btop (GPU, CPU, memory)
- Command runner pane: Execute AI-suggested commands

**User Input:**
> "A similar system to how we are using claude code now."
> "Terminal, ghostly to tmux will be the open on default interface for AI and the AI assistant."

**Rationale:**
1. **Familiar to Claude Code** - Similar split-pane interface
2. **100% local** - No API calls, runs entirely on-device
3. **Customizable** - User can modify appearance over time
4. **Context-aware** - System state injected into AI prompt
5. **Scriptable** - Easy for AI to generate and run commands

**TMUX Layout:**
```
┌───────────────────────────────┬──────────────┐
│ AI Chat (Qwen 32B Coder)     │ System       │
│                               │ Monitor      │
│                               │ (btop)       │
├───────────────────────────────┼──────────────┤
│ Command Runner                │              │
└───────────────────────────────┴──────────────┘
```

**System Context Injection:**
```bash
cat /var/lib/qalarc/system-state.json  # Full system state
cat /var/lib/qalarc/gpu-stats.json     # GPU utilization
cat /var/lib/qalarc/network-status.json # Network info
snapper list --json                     # Snapshots
```

**Alternatives Considered:**

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **VS Code extension** | Familiar IDE interface | Harder to customize, less scriptable, requires extension development | ❌ Rejected |
| **Standalone GUI app** | Polished UX | Time-consuming to build, less flexible | ❌ Rejected |
| **CLI only (no TMUX)** | Simplest | No persistent workspace, no split panes | ❌ Too basic |
| **TMUX + local model** | Scriptable, customizable, familiar to Claude Code | Requires TMUX knowledge | ✅ **SELECTED** |

**Future Customization:**
User mentioned wanting to change appearance over time - TMUX config allows:
- Custom color schemes
- Different pane layouts
- Alternative status bars
- Integration with other tools

---

### 9. Kernel: CachyOS vs Default NixOS vs Zen

**Date:** 2025-11-15
**Status:** ✅ Decided - CachyOS kernel with fallback

**Context:**
Need to decide on kernel for performance vs stability trade-off.

**Decision:**
**CachyOS kernel** (via Chaotic-Nyx) with automatic fallback to previous generations.

**User Question:**
> "Would Grub slow things down? Furthermore - can you assess what negative issues the cachyOS kernel might have? what would the default Nix kernel be? What does this mean?"

**Answer:**
- **GRUB:** ~2s boot delay, **no runtime performance impact**
- **Default NixOS kernel:** `linux_latest` (6.12.x) or `linux` LTS (6.6.x) - generic x86-64 baseline
- **CachyOS kernel risks:** Bleeding-edge patches, potential instability, broken with NixOS 25.05 (works with 25.11+)

**Rationale for CachyOS:**
1. **BORE scheduler** - Better responsiveness for desktop + AI workloads
2. **x86-64-v3 optimizations** - 10-20% faster for modern CPUs
3. **Latest AMD driver fixes** - Important for Ryzen AI Max+ 395
4. **Easy fallback** - GRUB keeps previous generations, can boot default kernel if needed

**Configuration:**
```nix
boot.kernelPackages = pkgs.linuxPackages_cachyos;  # Primary
# NixOS keeps previous generations - can rollback if CachyOS breaks
```

**Alternatives Considered:**

| Kernel | Optimizations | Stability | Verdict |
|--------|---------------|-----------|---------|
| **linux (LTS)** | None (generic x86-64) | Excellent | ❌ Too conservative |
| **linux_latest** | None (generic x86-64) | Good | ❌ Missing optimizations |
| **linux_zen** | Gaming/desktop patches | Good | ⚠️ Middle ground |
| **linux_cachyos** | BORE, x86-64-v3, patches | Fair (bleeding-edge) | ✅ **SELECTED** |

**Fallback Strategy:**
If CachyOS kernel breaks, user can:
1. Boot into previous generation from GRUB (has working kernel)
2. Comment out `boot.kernelPackages = pkgs.linuxPackages_cachyos;`
3. Rebuild with default kernel
4. No data loss, instant recovery

---

### 10. Documentation Format: LLM-Optimized Markdown

**Date:** 2025-11-15
**Status:** ✅ Decided - Structured Markdown with JSON examples

**Context:**
User wants documentation accessible to both humans and local coding models (Qwen).

**User Input:**
> "I want you to save and make notes of this whole brainstorming progress and information storage from these conversations to better guide the project and understand rational behind decisions."

**Decision:**
All documentation in **structured Markdown** with:
- Clear hierarchical headings
- Decision logs with explicit rationale
- Code blocks with syntax highlighting
- JSON examples for AI parsing
- Cross-references between docs

**Format Example:**
```markdown
## Decision: Topic

**Date:** YYYY-MM-DD
**Status:** ✅ Decided | ⚠️ In Progress | ❌ Rejected

**Context:**
[Background information]

**Decision:**
[What was decided]

**Rationale:**
1. Reason one
2. Reason two

**Alternatives Considered:**
| Option | Pros | Cons | Verdict |

**References:**
- [Links to research]
```

**AI-Friendly Features:**
- Machine-readable system state in `/var/lib/qalarc/*.json`
- All scripts output JSON with `--json` flag
- Clear command examples with expected output
- Explicit file paths and locations

**Rationale:**
1. **Human-readable** - Markdown is standard for docs
2. **LLM-friendly** - Structured format easy to parse
3. **Searchable** - Can grep/search through all decisions
4. **Historical record** - Captures "why" not just "what"

---

## Summary of Key Decisions

| Decision | Choice | Primary Rationale |
|----------|--------|-------------------|
| **OS** | NixOS + CachyOS kernel | Reproducibility + Performance |
| **Desktop** | KDE Plasma 6 + Krohnkite | Windows-familiar + Tiling |
| **Filesystem** | BTRFS with subvolumes | Snapshots + Compression |
| **Snapshots** | Snapper + grub-btrfs | Auto-snapshots + Boot menu |
| **AI Stack** | Ollama + PyTorch ROCm | Easy API + Flexibility |
| **Bootloader** | GRUB | Snapshot booting + Multi-OS |
| **VPN** | Tailscale | Zero-config + Mobile |
| **AI Interface** | TMUX + Qwen | Claude Code-like + Local |
| **Kernel** | CachyOS (with fallback) | Performance + Scheduler |
| **Docs** | Structured Markdown + JSON | Human + LLM readable |

---

**Last Updated:** 2025-11-15
**Document Version:** 1.0
**Maintained By:** fivelidz
