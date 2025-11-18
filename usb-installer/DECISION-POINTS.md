# qalarc_OS Installation Decision Points

## Where Do Users Make Decisions?

### Decision Timeline

```
Installation Media Boot
         ↓
[INSTALLER] Profile Selection
         ↓
[INSTALLER] Module Selection (if Custom)
         ↓
[INSTALLER] System Configuration
         ↓
[INSTALLER] Portable vs Standard
         ↓
[INSTALLER] Confirmation
         ↓
Installation Process
         ↓
First Boot
         ↓
[WELCOME WINDOW] Hardware Verification
         ↓
[WELCOME WINDOW] Model Downloads
         ↓
[SYSTEM] Additional Configuration
         ↓
[ONLINE] Community Profiles (future)
```

---

## During Installation (Text Installer)

### 1. Profile Selection
**When**: Step 2 of installer
**Type**: Required choice
**Options**:
- AI Workstation (Recommended)
- Gaming + AI
- Custom

**Details**:
- Cannot be changed easily after installation
- Determines installed packages
- Affects disk space requirements

**Can Change Later**: ❌ Requires reinstall or manual NixOS config editing

---

### 2. Module Selection
**When**: Step 3 of installer (Custom profile only)
**Type**: Optional toggles
**Options**:
- ollama (Local LLM Server)
- open-webui (Web UI for models)
- rocm (AMD GPU acceleration)
- docker (Containers)
- steam (Gaming)
- vscode (Code editor)
- python-ml (ML stack)
- textual (TUI framework)
- gaming-tools (Lutris, Heroic)
- obs (Recording software)

**Details**:
- Only shown if Custom profile selected
- Multiple selection allowed
- Adds specific packages to installation

**Can Change Later**: ✅ Via NixOS configuration editing

---

### 3. System Configuration
**When**: Step 4 of installer
**Type**: Required input
**Options**:
- Hostname (default: qalarc-workstation)
- Username (default: qalarc)
- Target Disk (select from available drives)

**Details**:
- Hostname and username are critical
- Cannot easily change username after creation
- Disk selection determines installation location

**Can Change Later**:
- Hostname: ✅ Easy (edit /etc/nixos/configuration.nix)
- Username: ❌ Difficult (requires manual migration)
- Disk: ❌ Requires reinstall

---

### 4. Portable Installation
**When**: Step 5 of installer (after disk selection)
**Type**: Automatic detection with user confirmation
**Trigger**: Installer detects removable drive
**Options**:
- Yes - Configure as portable (broad compatibility)
- No - Standard installation (hardware-optimized)

**Details**:
- Only asked if removable drive detected
- Affects kernel parameters and drivers
- Portable = works on multiple computers
- Standard = optimized for current hardware

**Can Change Later**: ⚠️ Requires manual configuration editing

---

### 5. Confirmation Summary
**When**: Step 6 of installer
**Type**: Review and confirm
**Shows**:
- Selected profile
- Hostname and username
- Target disk
- Installation type (portable/standard)
- VRAM detected

**Details**:
- Last chance to abort
- No changes after this point
- Installation begins immediately

---

## After Installation (Welcome Window)

### 6. Hardware Verification
**When**: First boot (automatic)
**Type**: Information only (no decisions)
**Shows**:
- CPU detection
- GPU detection
- RAM amount
- VRAM allocation status

**Actions Available**:
- View BIOS setup guide (if VRAM < 96GB)
- Refresh detection
- Continue to next screen

**Can Skip**: ✅ Yes (navigate away anytime)

---

### 7. Model Download Selection
**When**: First boot (Welcome Window)
**Type**: Optional selections
**Options**: 12+ models categorized by:
- **Large Models (70B+)**: For 96GB VRAM systems
  - Llama 3.3 70B
  - Qwen 2.5 72B
  - Mistral 123B
- **Coding Models**: For development
  - DeepSeek-Coder 33B
  - Code Llama 34B
  - Qwen Coder 32B
- **Lightweight Models**: Always available
  - Llama 3.2 3B
  - Llama 3.2 1B (pre-installed)

**Details**:
- VRAM-aware recommendations
- Shows which models fit in detected VRAM
- One-click downloads
- Can download multiple models
- Downloads in background

**Can Do Later**: ✅ Yes - Install models anytime via:
```bash
ollama pull model-name
```

---

### 8. System Tour
**When**: First boot (Welcome Window)
**Type**: Information only
**Shows**: All installed features and tools
**Actions**: Links to documentation, launch tools

**Can Skip**: ✅ Yes - Optional exploration

---

### 9. System Status
**When**: First boot (Welcome Window)
**Type**: Monitoring dashboard
**Shows**:
- Service status (Ollama, Docker, etc.)
- Disk usage
- VRAM allocation
- Installed models

**Actions**: Start/restart services, launch tools

---

## After First Boot (System Configuration)

### 10. BIOS Configuration
**When**: User-initiated (if VRAM < 96GB)
**Type**: Manual hardware configuration
**Location**: Computer BIOS/UEFI (F2/Del during boot)
**Action**: Set UMA Frame Buffer to 96GB

**Guide**: ~/Documents/qalarc-os-setup/BIOS-SETUP-GUIDE.md

**Required For**: Running large 70B+ models

---

### 11. NixOS Configuration
**When**: Anytime after installation
**Type**: Manual system customization
**Location**: /etc/nixos/configuration.nix
**Actions**:
- Add/remove packages
- Enable/disable services
- Modify system settings
- Apply with: `sudo nixos-rebuild switch`

**Can Do Anytime**: ✅ Yes - This is NixOS's strength

---

### 12. Additional Model Downloads
**When**: Anytime
**Type**: Command-line or Web UI
**Methods**:
1. **Terminal**:
   ```bash
   ollama pull model-name
   ```

2. **oterm** (Terminal UI):
   ```bash
   oterm
   ```

3. **Open WebUI** (Web interface):
   - Visit http://localhost:8080
   - Browse and download models

**Can Do Anytime**: ✅ Yes - Download as needed

---

## Future: Online Profile Repository

### 13. Community Profiles (Planned Phase 9)
**When**: After installation
**Type**: Optional online downloads
**Method**:
```bash
qalarc-profile pull <profile-name>
```

**Examples**:
- ml-researcher (extended ML tools)
- game-developer (Godot, Blender, engines)
- content-creator (video editing, graphics)
- web-developer (full web stack)

**Details**:
- Modular additions to base install
- Don't replace core system
- Can apply multiple profiles
- Stored in GitHub repository

**Status**: ⏳ Planned for Phase 9

---

## Decision Summary Matrix

| Decision | When | Can Change Later | Difficulty |
|----------|------|------------------|------------|
| **Profile** | Installer | ❌ Reinstall | Hard |
| **Modules** | Installer (Custom) | ✅ Config edit | Easy |
| **Hostname** | Installer | ✅ Config edit | Easy |
| **Username** | Installer | ⚠️ Manual migration | Hard |
| **Disk** | Installer | ❌ Reinstall | Hard |
| **Portable Mode** | Installer | ⚠️ Config edit | Medium |
| **Models** | Welcome Window | ✅ Anytime | Easy |
| **BIOS VRAM** | User-initiated | ✅ Anytime | Medium |
| **Packages** | NixOS config | ✅ Anytime | Easy |
| **Community Profiles** | Online (future) | ✅ Anytime | Easy |

---

## Recommendations

### For New Users

**Make These Decisions Carefully**:
- ✅ Profile (hard to change)
- ✅ Disk (can't change)
- ✅ Username (annoying to change)

**Don't Stress About**:
- ⏭️ Model downloads (add anytime)
- ⏭️ Hostname (easy to change)
- ⏭️ Additional packages (add via NixOS)

---

### For Portable Installation

**Key Decisions**:
1. **Disk**: Choose fast external drive (256GB+ recommended)
2. **Profile**: AI Workstation or Gaming+AI
3. **Portable Mode**: Select "Yes" when prompted

**Note**: VRAM configuration must be done on each computer separately

---

### For Fixed Installation

**Key Decisions**:
1. **Disk**: Choose internal drive or fast NVMe
2. **Profile**: Based on use case
3. **VRAM**: Configure BIOS for 96GB before or after install

**Note**: Optimized for specific hardware, best performance

---

## Where Installer Ends, User Begins

### Installer Handles
- ✅ Base system installation
- ✅ Profile package selection
- ✅ User and hostname setup
- ✅ Portable vs standard configuration
- ✅ Bootloader installation

### User Handles (After First Boot)
- ⏭️ BIOS VRAM configuration
- ⏭️ Model downloads
- ⏭️ Additional package installation
- ⏭️ Service configuration
- ⏭️ Customization and tweaking

---

## Decision Flow Diagram

```
┌─────────────────────────────────────┐
│   Boot Installation Media           │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│ SELECT PROFILE                      │
│ • AI Workstation (recommended)      │
│ • Gaming + AI                       │
│ • Custom                            │
│                                     │
│ ⚠️ Hard to change later             │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│ SELECT MODULES (if Custom)          │
│ [✓] Ollama                         │
│ [✓] ROCm                           │
│ [ ] Steam                          │
│ ...                                │
│                                    │
│ ✅ Can add more later               │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│ CONFIGURE SYSTEM                    │
│ Hostname: qalarc-workstation        │
│ Username: qalarc                    │
│ Disk: /dev/sdb (256GB)             │
│                                     │
│ ⚠️ Username hard to change          │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│ PORTABLE MODE?                      │
│                                     │
│ Detected: Removable drive (256GB)   │
│ Recommended: Yes                    │
│                                     │
│ [Y] Portable  [N] Standard         │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│ CONFIRM & INSTALL                   │
│                                     │
│ Review all selections               │
│ Last chance to abort                │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│ INSTALLATION COMPLETE               │
│ Reboot into qalarc_OS               │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│ WELCOME WINDOW                      │
│ • Hardware verification             │
│ • Model downloads (optional)        │
│ • System tour                       │
│ • Status dashboard                  │
│                                     │
│ ✅ All optional, can skip           │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│ SYSTEM READY                        │
│ • Configure BIOS if needed          │
│ • Download models as needed         │
│ • Customize via NixOS config        │
└─────────────────────────────────────┘
```

---

**Summary**: Critical decisions happen during installation (profile, disk, username). Everything else can be configured or downloaded later!

**Last Updated**: 2025-11-17
