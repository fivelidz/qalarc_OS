# QALARC OS - AGENT RULES (MANDATORY)

## ⚠️ READ THIS FIRST - ALL AGENTS

This document is **MANDATORY** for all sub-agents working on this repository.
Failure to follow these rules causes chaos and wastes human time.

---

## 🔴 CRITICAL RULES

### 1. NEVER REMOVE WORKING FEATURES
If something exists and was previously working, **DO NOT REMOVE IT** without:
- Explicit human approval
- Documented evidence it's broken
- A tested replacement ready

**Example of what NOT to do:**
```
❌ "CachyOS kernel requires source builds" → removes kernel
```

**What to do instead:**
```
✅ "CachyOS kernel build failed with error X. Investigating cause before any changes."
```

### 2. UNDERSTAND BEFORE CHANGING
Before modifying ANY system component:

1. **Read the flake.nix** - Understand what's configured
2. **Check for binary caches** - chaotic-nyx, cachix, etc. provide pre-built packages
3. **Review git history** - Was this working before?
4. **Test in isolation first** - Don't modify production configs

### 3. NO PERMISSION ASKING IN YOLO MODE
The user is in **EXTREME autonomous mode**. This means:
- Execute tasks immediately
- Don't ask "Should I proceed?"
- Don't ask "Is this okay?"
- Just do it and report results

**Bad:**
```
❌ "I found the issue. Should I fix it?"
❌ "I can modify this file. Do you want me to?"
```

**Good:**
```
✅ "Fixed the issue in X file. Here's what changed: ..."
✅ "Modified X, tested Y, result: working"
```

---

## 🟡 QALARC OS SPECIFIC KNOWLEDGE

### CachyOS Kernel Configuration

**This is WORKING and uses BINARY CACHE:**

```nix
# In flake.nix - provides pre-built CachyOS kernel
chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

# In outputs - enables the chaotic overlay
chaotic.nixosModules.default

# In host configs - uses the cached kernel
kernelPackages = pkgs.linuxPackages_cachyos;
```

**DO NOT CHANGE THIS** unless:
- The chaotic-nyx cache is offline (check status first)
- There's a documented incompatibility
- Human explicitly requests it

### Build Errors - Root Cause Analysis

If you see "source build required" errors:

1. **Check network connectivity to caches**
   ```bash
   curl -sI https://chaotic.cx/ | head -1
   ```

2. **Check if substituters are configured**
   ```bash
   nix show-config | grep substituters
   ```

3. **The fix is usually NOT to remove the package** - it's to:
   - Wait for cache availability
   - Add the cache to trusted substituters
   - Use `--option substitute true`

### Repository Structure

```
qalarc_OS/
├── flake.nix              # CRITICAL - all inputs and outputs
├── flake.lock             # Locked versions - don't touch without reason
├── hosts/                 # Machine configs
│   ├── gmktec-01/         # Primary target
│   ├── gmktec-01-single-drive/
│   ├── gmktec-01-minimal/
│   └── mini-pc-low-end/
├── modules/               # Feature modules
├── packages/              # Custom packages
└── docs/                  # User documentation
```

### Key Dependencies

| Component | Source | Binary Cache |
|-----------|--------|--------------|
| CachyOS Kernel | chaotic-nyx | ✅ Yes |
| ROCm packages | nixpkgs | ✅ Yes |
| Ollama | nixpkgs | ✅ Yes |
| Custom packages | local | ❌ No (build required) |

---

## 🟢 AGENT WORKFLOW

### Before Starting Any Task

1. **Read `AGENT_RULES.md`** (this file)
2. **Read `AGENT_CONTEXT.md`** for project context
3. **Check git status** - are there uncommitted changes?
4. **Understand the goal** - what are we actually trying to do?

### During Task Execution

1. **Make small, incremental changes**
2. **Test after each change when possible**
3. **Document what you changed and why**
4. **If something breaks, STOP and diagnose before "fixing"**

### After Task Completion

1. **Verify the change works**
2. **Stage changes appropriately** (`git add`)
3. **Write clear commit messages**
4. **Report results to parent agent/user**

---

## 🔵 COMMUNICATION PROTOCOL

### Reporting Errors

**Include:**
- Exact error message
- What command/action caused it
- What you tried
- What you recommend

**Format:**
```
ERROR: [brief description]
Command: [what was run]
Output: [relevant output]
Analysis: [what this means]
Recommendation: [what to do]
```

### Reporting Success

**Include:**
- What was done
- Files modified
- How to verify

**Format:**
```
DONE: [brief description]
Modified: [file list]
Verify: [how to test]
```

---

## ❌ COMMON MISTAKES TO AVOID

1. **Assuming "source build" = broken**
   - Binary caches may be temporarily unavailable
   - Check network/cache status first

2. **Removing features instead of fixing them**
   - Always diagnose the root cause
   - Removal is a last resort

3. **Not reading existing configuration**
   - The flake.nix has important context
   - Comments explain why things are configured

4. **Making multiple unrelated changes**
   - One task = one focused change
   - Don't scope creep

5. **Asking for permission in YOLO mode**
   - User has granted full autonomy
   - Act decisively, report results

---

## 📋 CHECKLIST FOR AGENTS

Before modifying configuration:
- [ ] Read flake.nix and understand inputs
- [ ] Check if feature uses binary cache
- [ ] Review git history for context
- [ ] Understand why current config exists

Before removing anything:
- [ ] Confirm it's actually broken (not just cache issue)
- [ ] Have evidence of the failure
- [ ] Human has approved removal OR
- [ ] Have working replacement ready

Before reporting "error":
- [ ] Diagnosed root cause
- [ ] Checked network/cache availability
- [ ] Tried obvious fixes first
- [ ] Can explain WHY it's failing

---

## 🚨 ESCALATION

If you encounter:
- Security vulnerabilities → Report immediately
- Data loss risk → Stop and alert
- Unclear requirements → Ask for clarification (this IS okay)
- Conflicting instructions → Ask for clarification

For everything else: **Act autonomously and report results.**
