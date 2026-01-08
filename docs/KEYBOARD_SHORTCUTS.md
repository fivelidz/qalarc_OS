# Keyboard Shortcuts Reference

**Master these shortcuts to work faster and more efficiently on Qalarc AI-OS!**

This guide covers all essential keyboard shortcuts for the desktop, terminal, TMUX, and AI tools.

---

## Quick Navigation

- [Essential Shortcuts](#essential-shortcuts) ⭐ Start here!
- [Desktop & Window Management](#desktop--window-management)
- [TMUX Shortcuts](#tmux-shortcuts)
- [AI-Specific Shortcuts](#ai-specific-shortcuts)
- [Terminal Shortcuts](#terminal-shortcuts)
- [Text Editing](#text-editing)
- [File Manager (Dolphin)](#file-manager-dolphin)
- [VS Code](#vs-code)
- [Printable Cheat Sheet](#printable-cheat-sheet)

---

## Essential Shortcuts

**The 10 shortcuts every user should know:**

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Super + Return` | Open terminal | Super = Windows key |
| `Alt + Space` | Search for apps | Quick launcher |
| `Alt + Tab` | Switch between windows | Hold Alt, tap Tab |
| `Super + L` | Lock screen | Secure your computer |
| `Ctrl + C` | Copy | Works everywhere |
| `Ctrl + V` | Paste | Works everywhere |
| `Ctrl + Z` | Undo | Works in most apps |
| `Alt + F4` | Close window | Quick exit |
| `Super + D` | Show desktop | Hide all windows |
| `Ctrl + Alt + T` | Open terminal | Alternative to Super+Return |

**💡 Tip:** `Super` key is the Windows logo key on most keyboards (or Command on Mac keyboards).

---

## Desktop & Window Management

### Application Launcher

| Shortcut | Action |
|----------|--------|
| `Alt + F1` | Open application menu |
| `Alt + Space` | Open KRunner (search) |
| `Alt + F2` | Open run command dialog |

### Window Control

| Shortcut | Action |
|----------|--------|
| `Alt + Tab` | Switch to next window |
| `Alt + Shift + Tab` | Switch to previous window |
| `Alt + F4` | Close current window |
| `Alt + F3` | Window operations menu |
| `Alt + F7` | Move window (arrow keys) |
| `Alt + F8` | Resize window (arrow keys) |

### Window Placement

| Shortcut | Action |
|----------|--------|
| `Super + Up` | Maximize window |
| `Super + Down` | Minimize/restore window |
| `Super + Left` | Snap window to left half |
| `Super + Right` | Snap window to right half |
| `Meta + F` | Toggle fullscreen |

### Virtual Desktops (Workspaces)

| Shortcut | Action |
|----------|--------|
| `Ctrl + F1` | Switch to Desktop 1 |
| `Ctrl + F2` | Switch to Desktop 2 |
| `Ctrl + F3` | Switch to Desktop 3 |
| `Ctrl + F4` | Switch to Desktop 4 |
| `Ctrl + Alt + Left` | Previous desktop |
| `Ctrl + Alt + Right` | Next desktop |

### Tiling Window Manager (Krohnkite)

| Shortcut | Action |
|----------|--------|
| `Meta + T` | Toggle tiling mode |
| `Meta + J` | Focus window below |
| `Meta + K` | Focus window above |
| `Meta + H` | Focus window left |
| `Meta + L` | Focus window right |
| `Meta + Shift + J` | Move window down |
| `Meta + Shift + K` | Move window up |
| `Meta + Shift + H` | Move window left |
| `Meta + Shift + L` | Move window right |
| `Meta + F` | Float current window |

**Note:** `Meta` key is typically the Alt key in tiling shortcuts.

### Desktop & Screen

| Shortcut | Action |
|----------|--------|
| `Super + D` | Show desktop (minimize all) |
| `Super + W` | Show all windows (overview) |
| `Super + Tab` | Show window switcher |
| `Super + L` | Lock screen |
| `Ctrl + Alt + L` | Lock screen (alternative) |
| `Ctrl + Alt + Del` | Log out dialog |

---

## TMUX Shortcuts

**TMUX Prefix:** `Ctrl + A` (press and release, then press next key)

### Pane Management

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Ctrl+A` then `\|` | Split vertically | Creates left/right panes |
| `Ctrl+A` then `-` | Split horizontally | Creates top/bottom panes |
| `Ctrl+A` then `x` | Close current pane | No confirmation |
| `Alt + ←` | Move to left pane | No prefix needed! |
| `Alt + →` | Move to right pane | No prefix needed! |
| `Alt + ↑` | Move to pane above | No prefix needed! |
| `Alt + ↓` | Move to pane below | No prefix needed! |
| `Ctrl+A` then `o` | Cycle through panes | Alternative navigation |
| `Ctrl+A` then `z` | Zoom current pane | Toggle fullscreen |
| `Ctrl+A` then `{` | Swap pane with previous | |
| `Ctrl+A` then `}` | Swap pane with next | |

### Window Management

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Ctrl+A` then `c` | Create new window | Like a new tab |
| `Ctrl+A` then `n` | Next window | |
| `Ctrl+A` then `p` | Previous window | |
| `Ctrl+A` then `0-9` | Switch to window 0-9 | Direct access |
| `Ctrl+A` then `w` | List all windows | Interactive selector |
| `Ctrl+A` then `,` | Rename current window | |
| `Ctrl+A` then `&` | Kill current window | Confirms first |
| `Shift + ←` | Previous window | No prefix needed! |
| `Shift + →` | Next window | No prefix needed! |

### Session Management

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Ctrl+A` then `d` | Detach session | Keeps running |
| `Ctrl+A` then `$` | Rename session | |
| `Ctrl+A` then `s` | List all sessions | Interactive selector |
| `Ctrl+A` then `(` | Previous session | |
| `Ctrl+A` then `)` | Next session | |

**Command line session management:**
```bash
tmux list-sessions          # List all sessions
tmux attach -t <name>       # Attach to session
tmux kill-session -t <name> # Delete session
```

### Copy Mode (Scrolling)

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Ctrl+A` then `[` | Enter copy mode | Enables scrolling |
| `Ctrl+K` | Enter copy mode | Alternative |
| `q` | Exit copy mode | |
| `↑ ↓` | Scroll up/down | Line by line |
| `Ctrl+U` | Scroll half page up | |
| `Ctrl+D` | Scroll half page down | |
| `g` | Go to top | |
| `G` | Go to bottom | |
| `v` | Start selection | Vim-style |
| `y` | Copy selection | Vim-style |

### AI-Specific TMUX Shortcuts

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Ctrl+A` then `o` | Open Claude Code | New pane |
| `Ctrl+A` then `O` | Open OpenCode | New pane |
| `Ctrl+A` then `Ctrl+v` | Claude in vertical split | |
| `Ctrl+A` then `Ctrl+h` | Claude in horizontal split | |

### TMUX Configuration

| Shortcut | Action |
|----------|--------|
| `Ctrl+A` then `r` | Reload TMUX config |
| `Ctrl+A` then `?` | Show all keybindings |

---

## AI-Specific Shortcuts

### System-Wide AI Access

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Super + A` | Quick AI launcher | Opens AI selection menu |

### In OpenCode/Claude Code

| Shortcut | Action |
|----------|--------|
| `Ctrl + C` | Cancel AI response | Stop generation |
| `Ctrl + D` | Exit AI session | Returns to shell |
| `Ctrl + L` | Clear screen | Clean slate |
| `↑ ↓` | Browse message history | |

### Quick Commands

**Type these in AI chat:**

| Command | Action |
|---------|--------|
| `/bye` | Exit chat |
| `/model <name>` | Switch model |
| `/system` | Show system info |
| `/gpu` | Show GPU stats |
| `/exit` | Exit workspace |

---

## Terminal Shortcuts

### Essential Terminal

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Ctrl + C` | Cancel current command | Force stop |
| `Ctrl + D` | Exit terminal | Or end of input |
| `Ctrl + L` | Clear screen | Same as `clear` |
| `Ctrl + Z` | Suspend process | Use `fg` to resume |
| `Ctrl + R` | Search history | Type to search |
| `Tab` | Auto-complete | Press twice for options |
| `↑` | Previous command | |
| `↓` | Next command | |
| `Ctrl + U` | Clear line before cursor | |
| `Ctrl + K` | Clear line after cursor | |
| `Ctrl + W` | Delete word before cursor | |

### Cursor Movement

| Shortcut | Action |
|----------|--------|
| `Ctrl + A` | Move to start of line |
| `Ctrl + E` | Move to end of line |
| `Alt + B` | Move back one word |
| `Alt + F` | Move forward one word |
| `Ctrl + XX` | Toggle between start and current position |

### Process Management

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Ctrl + C` | Kill current process | SIGINT |
| `Ctrl + Z` | Suspend process | Background it |
| `Ctrl + D` | Send EOF | Exits shells |

**Commands for suspended processes:**
```bash
jobs           # List background jobs
fg             # Bring job to foreground
bg             # Resume job in background
kill %1        # Kill job 1
```

---

## Text Editing

### Universal Text Shortcuts

**Work in most applications (Kate, VS Code, browsers, etc.):**

| Shortcut | Action |
|----------|--------|
| `Ctrl + C` | Copy |
| `Ctrl + X` | Cut |
| `Ctrl + V` | Paste |
| `Ctrl + Z` | Undo |
| `Ctrl + Shift + Z` | Redo |
| `Ctrl + A` | Select all |
| `Ctrl + F` | Find |
| `Ctrl + H` | Find and replace |
| `Ctrl + S` | Save |
| `Ctrl + Shift + S` | Save as |
| `Ctrl + W` | Close tab/document |
| `Ctrl + Q` | Quit application |

### Kate Text Editor

| Shortcut | Action |
|----------|--------|
| `Ctrl + N` | New document |
| `Ctrl + O` | Open file |
| `Ctrl + T` | New tab |
| `Ctrl + Shift + T` | Reopen closed tab |
| `F11` | Toggle fullscreen |
| `Ctrl + Shift + E` | Toggle file browser |
| `Ctrl + /` | Comment/uncomment |

### Nano (Terminal Text Editor)

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Ctrl + O` | Save (WriteOut) | Then press Enter |
| `Ctrl + X` | Exit | Prompts to save if modified |
| `Ctrl + K` | Cut line | |
| `Ctrl + U` | Paste | |
| `Ctrl + W` | Search | |
| `Ctrl + \` | Replace | |
| `Alt + A` | Start selection | Then move cursor |
| `Ctrl + 6` | Start selection | Alternative |

---

## File Manager (Dolphin)

| Shortcut | Action |
|----------|--------|
| `Ctrl + N` | New window |
| `Ctrl + T` | New tab |
| `Ctrl + W` | Close tab |
| `Ctrl + L` | Edit location bar |
| `Alt + Up` | Navigate to parent folder |
| `Alt + Left` | Back |
| `Alt + Right` | Forward |
| `F3` | Split view |
| `F4` | Open terminal here |
| `F10` | Create folder |
| `Shift + Delete` | Delete permanently (skip trash) |
| `Ctrl + H` | Show hidden files |
| `Ctrl + +` | Zoom in (larger icons) |
| `Ctrl + -` | Zoom out (smaller icons) |

### File Operations

| Shortcut | Action |
|----------|--------|
| `F2` | Rename file |
| `Delete` | Move to trash |
| `Shift + Delete` | Delete permanently |
| `Ctrl + C` | Copy |
| `Ctrl + X` | Cut |
| `Ctrl + V` | Paste |
| `Ctrl + A` | Select all |
| `Ctrl + Shift + N` | New folder |

---

## VS Code

### Essential VS Code

| Shortcut | Action |
|----------|--------|
| `Ctrl + P` | Quick file open |
| `Ctrl + Shift + P` | Command palette |
| `Ctrl + B` | Toggle sidebar |
| `Ctrl + J` | Toggle terminal |
| `Ctrl + \`` | Toggle terminal (alternative) |
| `Ctrl + Shift + E` | Explorer |
| `Ctrl + Shift + F` | Search in files |
| `Ctrl + Shift + G` | Source control (Git) |
| `F5` | Start debugging |
| `Ctrl + K Ctrl + S` | Keyboard shortcuts reference |

### Editing

| Shortcut | Action |
|----------|--------|
| `Ctrl + /` | Toggle comment |
| `Ctrl + Shift + K` | Delete line |
| `Alt + Up/Down` | Move line up/down |
| `Ctrl + Shift + D` | Duplicate line |
| `Ctrl + D` | Select next occurrence |
| `Ctrl + Shift + L` | Select all occurrences |
| `Alt + Click` | Add cursor |
| `Ctrl + Alt + Up/Down` | Add cursor above/below |

### Navigation

| Shortcut | Action |
|----------|--------|
| `Ctrl + G` | Go to line |
| `Ctrl + Tab` | Switch between open files |
| `Alt + Left/Right` | Navigate back/forward |
| `Ctrl + Shift + O` | Go to symbol in file |
| `Ctrl + T` | Go to symbol in workspace |

---

## System Shortcuts

### System Control

| Shortcut | Action |
|----------|--------|
| `Ctrl + Alt + Esc` | Kill window (click to kill) |
| `Print` | Screenshot (full screen) |
| `Shift + Print` | Screenshot (region) |
| `Ctrl + Print` | Screenshot (window) |

### Qalarc-Specific

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Super + Shift + S` | Create snapshot | BTRFS snapshot |

**Commands for snapshots:**
```bash
qalarc-snapshot "description"  # Create snapshot
snapper list                   # List snapshots
snapper rollback <number>      # Rollback
```

---

## Browser Shortcuts

### Works in Firefox, Brave, Chrome

| Shortcut | Action |
|----------|--------|
| `Ctrl + T` | New tab |
| `Ctrl + Shift + T` | Reopen closed tab |
| `Ctrl + W` | Close tab |
| `Ctrl + Tab` | Next tab |
| `Ctrl + Shift + Tab` | Previous tab |
| `Ctrl + L` | Focus address bar |
| `Ctrl + F` | Find in page |
| `Ctrl + H` | History |
| `Ctrl + Shift + Delete` | Clear browsing data |
| `F11` | Fullscreen |
| `Ctrl + +` | Zoom in |
| `Ctrl + -` | Zoom out |
| `Ctrl + 0` | Reset zoom |

---

## Printable Cheat Sheet

### Quick Reference Card

**Print this section and keep it near your computer!**

---

**🖥️ QALARC AI-OS KEYBOARD SHORTCUTS**

**ESSENTIAL (Learn These First!)**
```
Super + Return       Open Terminal
Alt + Space          Search Apps
Alt + Tab            Switch Windows
Super + L            Lock Screen
Super + D            Show Desktop
```

**WINDOW MANAGEMENT**
```
Super + ←/→          Snap Left/Right
Super + ↑            Maximize
Alt + F4             Close Window
Ctrl + F1/F2/F3      Switch Desktop
```

**TMUX (Terminal Multiplexer)**
```
Prefix = Ctrl+A (press and release first)

Ctrl+A then |        Split Vertical
Ctrl+A then -        Split Horizontal
Alt + Arrows         Switch Panes (no prefix!)
Shift + ←/→          Switch Windows (no prefix!)
Ctrl+A then o        Open Claude Code
Ctrl+A then O        Open OpenCode
Ctrl+A then d        Detach Session
```

**TERMINAL**
```
Ctrl + C             Cancel Command
Ctrl + L             Clear Screen
Ctrl + R             Search History
Tab                  Auto-complete
↑/↓                  Command History
```

**TEXT EDITING**
```
Ctrl + C/X/V         Copy/Cut/Paste
Ctrl + Z             Undo
Ctrl + S             Save
Ctrl + F             Find
Ctrl + A             Select All
```

**AI TOOLS**
```
Super + A            Quick AI Launcher
Ctrl + D             Exit AI Chat
/bye                 Exit Ollama Chat
```

**SYSTEM**
```
Ctrl + Alt + T       Open Terminal
Print                Screenshot
Super + Shift + S    Create Snapshot
```

---

## Customizing Shortcuts

### Change Keyboard Shortcuts

**1. Open System Settings:**
```
Application Launcher → System Settings → Shortcuts
```

**2. Find the shortcut you want to change**

**3. Click on the shortcut**

**4. Press your desired key combination**

**5. Click OK**

### Create Custom Shortcuts

**Example: Add shortcut for OpenCode**

1. System Settings → Shortcuts → Custom Shortcuts
2. Click "Edit" → "New" → "Global Shortcut" → "Command/URL"
3. Trigger: Choose your shortcut (e.g., `Ctrl + Alt + A`)
4. Action: Command to run: `qalarc-open-in-ai $(pwd)`
5. Apply

### Reset to Defaults

System Settings → Shortcuts → Reset to defaults

---

## Learning Tips

**How to master shortcuts:**

1. **Start with essentials** (top 10 shortcuts)
2. **Learn one category per week**
   - Week 1: Essential shortcuts
   - Week 2: Window management
   - Week 3: TMUX
   - Week 4: Terminal
3. **Practice daily** - Force yourself to use shortcuts instead of mouse
4. **Print the cheat sheet** and keep it visible
5. **Teach someone else** - best way to remember!

**Common mistakes:**
- ❌ Trying to learn everything at once
- ❌ Not practicing regularly
- ❌ Giving up and using mouse

**Success strategy:**
- ✅ Learn 2-3 shortcuts per day
- ✅ Use them for a week before adding more
- ✅ Focus on shortcuts for tasks you do often

---

## Quick Help

**Built-in help:**
```bash
qalarc-explain          # Interactive help menu
```

**Show all TMUX shortcuts:**
```
Ctrl+A then ?
```

**VS Code shortcuts:**
```
Ctrl + K, Ctrl + S
```

**System Settings:**
```
Application Launcher → System Settings → Shortcuts
```

---

## Next Steps

Now that you know the shortcuts:

1. **Print the cheat sheet** section
2. **Practice 10 minutes daily** for one week
3. **Customize** shortcuts to fit your workflow
4. **Share** your favorite shortcuts with others!

**Related Guides:**
- [GETTING_STARTED.md](./GETTING_STARTED.md) - Basic desktop usage
- [AI_CODING_TUTORIAL.md](./AI_CODING_TUTORIAL.md) - AI tool workflows
- [TMUX_BASICS.md] - Deep dive into TMUX

---

**Work smarter, not harder!** ⚡

*Master these shortcuts and you'll be 10x more productive!*

*Last updated: January 2026*
