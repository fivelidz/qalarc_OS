# Getting Started with Qalarc AI-OS

**Welcome!** This guide will help you get started with your new Qalarc AI-OS system. Don't worry if you're new to Linux - we'll walk through everything step by step.

---

## What is Qalarc AI-OS?

Think of Qalarc AI-OS as a specialized operating system designed specifically for running AI models on your computer. It's like having a personal AI assistant that lives on your machine instead of in the cloud.

**Key Benefits:**
- **Privacy First**: Your AI conversations never leave your computer
- **Always Available**: No internet required once models are downloaded
- **Powerful**: Optimized for the AMD Ryzen AI Max+ chip with up to 96GB of AI memory
- **Safe**: Automatic snapshots let you undo changes if something goes wrong
- **Free**: No subscription fees or API costs

**What makes it special?**
- Built on NixOS (a reliable, reproducible Linux system)
- Pre-configured with AI coding tools (Claude Code, OpenCode)
- Beautiful KDE Plasma desktop (similar to Windows)
- Automatic backups with time-travel features

---

## First Boot Walkthrough

### 1. Power On and Initial Screen

When you first boot your system:

1. **Power button**: Press once to turn on
2. **Boot screen**: You'll see the Qalarc logo (wait 10-30 seconds)
3. **Login screen**: A graphical login screen will appear

[SCREENSHOT: Login screen with Qalarc branding]

### 2. Logging In

**Default credentials** (if not changed during installation):
- **Username**: Your chosen username (example: `qalarc`)
- **Password**: Your chosen password

**Tips:**
- Click the username field and type your username
- Press Tab to move to the password field
- Press Enter to login

**First-time login**: The system may take 30-60 seconds to set up your desktop environment.

### 3. Welcome Wizard (First Boot)

On first login, you'll see the Qalarc Welcome Wizard:

[SCREENSHOT: Welcome wizard dialog]

**The wizard will help you:**
1. Choose your timezone and language
2. Connect to WiFi/network
3. Download your first AI model
4. Take a quick tour of the desktop

**Recommended action**: Follow the wizard all the way through - it only takes 5 minutes!

---

## Setting Up Your User Account

### Profile Customization

**Access System Settings:**
1. Click the **Application Launcher** (bottom-left corner, looks like Qalarc logo)
2. Type "System Settings"
3. Click **System Settings**

[SCREENSHOT: Application launcher with System Settings highlighted]

### User Information

Navigate to **System Settings → Users**:

- **Change your avatar**: Click the profile picture
- **Update your name**: Click "Full Name" to edit
- **Change password**: Click "Change Password" button

### Desktop Preferences

**Appearance** (System Settings → Appearance):
- **Theme**: Choose Light or Dark mode
- **Wallpaper**: Right-click desktop → "Configure Desktop and Wallpaper"
- **Colors**: Qalarc comes with a custom green/black theme

**Quick Theme Switch:**
- Click the battery/wifi area (system tray) in the bottom-right
- Click the moon icon to toggle dark mode

[SCREENSHOT: System tray with theme toggle highlighted]

---

## Connecting to WiFi/Network

### WiFi Connection

**Method 1: System Tray (Easiest)**

1. **Click the network icon** in the bottom-right corner (system tray)
2. **Find your network** in the list
3. **Click your network name**
4. **Enter password** when prompted
5. **Click "Connect"**

[SCREENSHOT: Network menu with available networks]

**Method 2: Settings**

1. Open **System Settings**
2. Navigate to **Connections**
3. Click **Add new connection** → **WiFi**
4. Select your network and enter password

### Ethernet (Wired) Connection

**Most wired connections work automatically!**

- Just plug in the ethernet cable
- Wait 5-10 seconds
- You should see a "Connected" notification

**Verify connection:**
- Open a web browser (click Firefox or Brave icon in taskbar)
- Try visiting a website

### Troubleshooting Network Issues

**WiFi not showing up?**
1. Make sure WiFi is enabled: Click network icon → "Enable WiFi"
2. Check hardware switch (some laptops have a physical WiFi switch)

**Can't connect?**
1. Double-check password (passwords are case-sensitive!)
2. Try restarting the network:
   - Open terminal (see next section)
   - Type: `sudo systemctl restart NetworkManager`
   - Enter your password

**Still having issues?**
- See the [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) guide
- Check router settings (make sure MAC filtering isn't enabled)

---

## Basic Desktop Navigation (KDE Plasma)

Qalarc uses **KDE Plasma**, a user-friendly desktop that works similarly to Windows.

### Main Desktop Components

[SCREENSHOT: Labeled desktop showing taskbar, system tray, application launcher]

**1. Application Launcher** (Bottom-left)
- Click to open the app menu
- Type to search for apps
- Recent apps appear at the top

**2. Taskbar** (Bottom)
- Shows running applications
- Click icons to switch between apps
- Right-click for window options

**3. System Tray** (Bottom-right)
- Network, volume, notifications
- Click icons for quick settings
- Date/time display

**4. Desktop Area**
- Double-click icons to open
- Right-click for options
- Middle-click to show all windows

### Opening Applications

**Three ways to open apps:**

**1. Application Launcher** (recommended for beginners)
   - Click the Qalarc logo (bottom-left)
   - Browse categories OR type to search
   - Click the app you want

**2. Search Bar**
   - Press `Alt + Space` (or `Alt + F2`)
   - Type app name
   - Press Enter

**3. Favorites Bar**
   - Pinned apps appear in the taskbar
   - Single click to launch

### Essential Applications

**Pre-installed apps you'll use:**

- **Firefox/Brave**: Web browsers
- **Ghostty**: Terminal (for AI coding and commands)
- **Dolphin**: File manager (like Windows Explorer)
- **Kate**: Text editor
- **VS Code**: Code editor
- **System Monitor**: Check CPU/RAM usage

**To find an app**: Click launcher → Type the app name → Press Enter

### Managing Windows

**Window Controls** (Top-right of each window):
- **─** Minimize (hide window)
- **□** Maximize (fill screen)
- **✕** Close window

**Window Management Shortcuts:**
- `Alt + Tab`: Switch between windows
- `Alt + F4`: Close current window
- `Super + Up`: Maximize window
- `Super + Down`: Restore/minimize window

**Super Key = Windows Key** on most keyboards

### Virtual Desktops (Workspaces)

Think of these as multiple desktops you can switch between.

**Why use them?**
- Keep work projects on Desktop 1
- Keep AI coding on Desktop 2
- Keep web browsing on Desktop 3

**How to use:**
- **Switch desktops**: `Ctrl + F1/F2/F3/F4`
- **Move window to desktop**: Right-click title bar → "To Desktop"
- **View all desktops**: Click "Show Desktop Grid" button

[SCREENSHOT: Desktop switcher in taskbar]

### File Manager (Dolphin)

**Opening files and folders:**

1. **Click Dolphin** icon in taskbar (folder icon)
2. **Common locations** are in the left sidebar:
   - **Home**: Your personal files
   - **Desktop**: Files on your desktop
   - **Documents**: Documents folder
   - **Downloads**: Downloaded files

**Navigation:**
- Click folders to open them
- Click "Back" button to go up
- Use breadcrumb bar at top to jump to parent folders

**Right-click menus:**
- Right-click files/folders for options
- **"Open in AI"**: Opens folder in AI coding assistant (see AI tutorial)
- Copy, paste, rename, delete all work here

---

## Your First Steps After Setup

### 1. Update Your System (Recommended)

Keep your system up to date for best performance:

**Easy method:**
1. Open **Discover** (app store)
2. Click **Updates** at the bottom
3. Click **Update All**

**Command line method** (if comfortable):
```bash
cd ~/qalarc_OS
nix flake update
sudo nixos-rebuild switch --flake .#gmktec-01
```

### 2. Download Your First AI Model

See [OLLAMA_MODELS_GUIDE.md](./OLLAMA_MODELS_GUIDE.md) for detailed instructions.

**Quick start:**
1. Open **Ghostty** terminal (Application Launcher → Ghostty)
2. Type: `ollama pull qwen2.5-coder:7b`
3. Wait for download (3-5 minutes for small models)

### 3. Try the AI Coding Assistant

1. **Right-click any folder** in file manager
2. Select **"Open in AI"**
3. Choose **OpenCode (Local Models)**
4. Pick a model from the list
5. Start chatting with your AI!

See [AI_CODING_TUTORIAL.md](./AI_CODING_TUTORIAL.md) for more details.

### 4. Explore Pre-installed Software

**Web Browsing:**
- Brave (privacy-focused)
- Firefox (popular, open-source)

**Media:**
- VLC (video player)
- Spotify (if you add it)

**Productivity:**
- LibreOffice (like Microsoft Office)
- GIMP (image editing)
- Kdenlive (video editing)

**Development:**
- VS Code (code editor)
- Neovim (advanced text editor)
- Git (version control)

---

## Quick Reference: Most Important Things

### Getting Help

**Built-in help system:**
```bash
qalarc-explain
```
Opens an interactive menu with tutorials and tips.

**Documentation location:**
- All docs are in: `~/qalarc_OS/docs/`
- Open with: `kate ~/qalarc_OS/docs/GETTING_STARTED.md`

### Most-Used Shortcuts

| Shortcut | Action |
|----------|--------|
| `Super + Return` | Open terminal |
| `Alt + Space` | Search for apps |
| `Alt + Tab` | Switch windows |
| `Super + L` | Lock screen |
| `Ctrl + Alt + T` | Open terminal (alternative) |
| `Ctrl + C` | Copy |
| `Ctrl + V` | Paste |
| `Ctrl + Z` | Undo |

**Note**: `Super` = Windows key on your keyboard

### Emergency: Undo Changes

If something breaks, you can **roll back** to a previous snapshot:

**Method 1: From running system**
```bash
snapper list              # See all snapshots
snapper rollback <number> # Rollback to specific snapshot
sudo reboot
```

**Method 2: From boot menu**
1. Restart computer
2. At GRUB menu, select **"NixOS - Snapshots"**
3. Choose a snapshot from before the problem
4. Boot into that snapshot

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for more recovery options.

---

## What's Next?

Now that you're familiar with the basics:

1. **[AI_CODING_TUTORIAL.md](./AI_CODING_TUTORIAL.md)** - Learn to use AI assistants
2. **[OLLAMA_MODELS_GUIDE.md](./OLLAMA_MODELS_GUIDE.md)** - Download and manage AI models
3. **[KEYBOARD_SHORTCUTS.md](./KEYBOARD_SHORTCUTS.md)** - Become more efficient
4. **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** - Fix common issues

---

## Getting Help

**Need more help?**

- **Built-in help**: Run `qalarc-explain` in terminal
- **Documentation**: All guides are in `~/qalarc_OS/docs/`
- **Community**: Visit https://qalarc.com
- **Email support**: team@qalarc.com

**Remember**: There are no "dumb questions" - everyone starts as a beginner! The AI assistant is always ready to help you learn.

---

**Welcome to the Qalarc AI-OS community!** 🎉

*Last updated: January 2026*
