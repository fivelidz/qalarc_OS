{ config, pkgs, lib, ... }:

{
  # AI Coding Environment Module
  # Includes: Claude Code, OpenCode, TMUX (matching fivelidz config), Ghostty

  environment.systemPackages = with pkgs; [
    # AI Coding Assistants
    claude-code
    opencode
    
    # Terminal and Multiplexer
    ghostty
    # tmux installed via programs.tmux below
    
    # Code editors with AI support
    neovim
    vscode
    
    # Useful CLI tools for AI coding
    ripgrep
    fd
    bat
    eza
    lazygit
    btop
    
    # GUI dependencies for dialogs
    kdePackages.kdialog
    yad  # fallback GTK dialog
    
    # ========================================================================
    # qalarc-open-in-ai - Right-click "Open in AI" launcher
    # ========================================================================
    # Shows a GUI to select AI model/agent, then opens folder in OpenCode
    (writeShellScriptBin "qalarc-open-in-ai" ''
      #!/usr/bin/env bash
      
      # Qalarc "Open in AI" - GUI launcher for AI coding assistants
      # Called from Dolphin right-click menu
      
      TARGET_DIR="''${1:-.}"
      cd "$TARGET_DIR" || exit 1
      
      # Get list of available Ollama models
      get_models() {
        if command -v ollama &> /dev/null && systemctl is-active ollama &>/dev/null; then
          ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' | head -20
        else
          echo "qwen2.5-coder:32b"
          echo "llama3.3:70b"
          echo "deepseek-coder:33b"
          echo "codellama:34b"
          echo "mistral:7b"
        fi
      }
      
      # Build model list for dialog
      MODELS=$(get_models)
      
      # Use kdialog (KDE) or yad (GTK fallback) for GUI
      if command -v kdialog &> /dev/null; then
        # KDE Dialog - looks native in Plasma
        
        # First, choose the AI tool
        TOOL=$(kdialog --title "Open in AI" \
          --menu "Choose AI Assistant:" \
          "opencode" "OpenCode (Local Models - Offline)" \
          "claude" "Claude Code (Cloud - Requires API Key)" \
          "chat" "Just Chat (Ollama Direct)")
        
        if [ -z "$TOOL" ]; then
          exit 0  # User cancelled
        fi
        
        if [ "$TOOL" = "claude" ]; then
          # Launch Claude Code directly
          ghostty --working-directory="$TARGET_DIR" -e claude
          exit 0
        fi
        
        if [ "$TOOL" = "chat" ]; then
          # Show model selector for direct chat
          MODEL_LIST=""
          for model in $MODELS; do
            MODEL_LIST="$MODEL_LIST $model $model"
          done
          
          SELECTED_MODEL=$(kdialog --title "Select Model" \
            --menu "Choose a model to chat with:" $MODEL_LIST)
          
          if [ -n "$SELECTED_MODEL" ]; then
            ghostty --working-directory="$TARGET_DIR" -e ollama run "$SELECTED_MODEL"
          fi
          exit 0
        fi
        
        # OpenCode - show agent/model selection
        AGENT=$(kdialog --title "OpenCode Agent" \
          --menu "Choose coding agent style:" \
          "coder" "Coder (Write & edit code)" \
          "architect" "Architect (Plan & design)" \
          "reviewer" "Reviewer (Code review)" \
          "debugger" "Debugger (Find & fix bugs)" \
          "default" "Default (General assistant)")
        
        if [ -z "$AGENT" ]; then
          AGENT="default"
        fi
        
        # Select model
        MODEL_LIST=""
        for model in $MODELS; do
          MODEL_LIST="$MODEL_LIST $model $model"
        done
        
        SELECTED_MODEL=$(kdialog --title "Select Model" \
          --menu "Choose AI model for coding:" \
          "auto" "Auto (Use configured default)" \
          $MODEL_LIST)
        
        if [ -z "$SELECTED_MODEL" ]; then
          SELECTED_MODEL="auto"
        fi
        
      else
        # Fallback to yad (GTK dialog)
        TOOL=$(yad --title="Open in AI" --center --width=400 \
          --list --radiolist --column="" --column="Tool" --column="Description" \
          TRUE "opencode" "OpenCode (Local Models)" \
          FALSE "claude" "Claude Code (Cloud)" \
          FALSE "chat" "Just Chat" \
          --print-column=2 --separator="")
        
        if [ -z "$TOOL" ]; then
          exit 0
        fi
        
        AGENT="default"
        SELECTED_MODEL="auto"
      fi
      
      # Launch in Ghostty terminal
      if [ "$TOOL" = "opencode" ]; then
        if [ "$SELECTED_MODEL" = "auto" ]; then
          ghostty --working-directory="$TARGET_DIR" -e opencode
        else
          # Set model via environment variable (OpenCode respects OLLAMA_MODEL)
          ghostty --working-directory="$TARGET_DIR" -e bash -c "OLLAMA_MODEL=$SELECTED_MODEL opencode"
        fi
      fi
    '')
    
    # ========================================================================
    # qalarc-ai-quick - Quick AI access from anywhere (Super+A shortcut)
    # ========================================================================
    (writeShellScriptBin "qalarc-ai-quick" ''
      #!/usr/bin/env bash
      
      # Quick AI launcher - bound to Super+A
      # Opens in current directory or prompts for folder
      
      if command -v kdialog &> /dev/null; then
        CHOICE=$(kdialog --title "Qalarc AI" \
          --menu "Quick AI Access:" \
          "here" "Open AI in current folder" \
          "browse" "Browse for folder..." \
          "workspace" "Open AI Workspace (TMUX)" \
          "models" "Manage Ollama models")
        
        case "$CHOICE" in
          "here")
            qalarc-open-in-ai "$(pwd)"
            ;;
          "browse")
            FOLDER=$(kdialog --getexistingdirectory ~)
            if [ -n "$FOLDER" ]; then
              qalarc-open-in-ai "$FOLDER"
            fi
            ;;
          "workspace")
            ghostty -e qalarc-ai-workspace
            ;;
          "models")
            ghostty -e bash -c "echo 'Ollama Model Manager'; echo; ollama list; echo; echo 'Commands: ollama pull <model>, ollama rm <model>'; echo; exec bash"
            ;;
        esac
      fi
    '')

    # qalarc-ai-workspace script (TMUX-based coding environment)
    (writeShellScriptBin "qalarc-ai-workspace" ''
      #!/usr/bin/env bash
      
      # Qalarc AI Workspace - Claude Code-like experience with local models
      
      SESSION_NAME="qalarc-ai"
      
      # Check if session exists
      tmux has-session -t $SESSION_NAME 2>/dev/null
      
      if [ $? != 0 ]; then
        # Create new session with our layout
        tmux new-session -d -s $SESSION_NAME -n "ai-workspace"
        
        # Split into panes
        # Main pane (left) - AI chat
        tmux send-keys -t $SESSION_NAME "echo 'Welcome to Qalarc AI Workspace'" Enter
        tmux send-keys -t $SESSION_NAME "echo 'Starting Ollama...'" Enter
        tmux send-keys -t $SESSION_NAME "echo" Enter
        tmux send-keys -t $SESSION_NAME "echo 'Commands:'" Enter
        tmux send-keys -t $SESSION_NAME "echo '  claude        - Start Claude Code'" Enter
        tmux send-keys -t $SESSION_NAME "echo '  opencode      - Start OpenCode (local models)'" Enter
        tmux send-keys -t $SESSION_NAME "echo '  ollama run <model> - Chat with model'" Enter
        tmux send-keys -t $SESSION_NAME "echo" Enter
        
        # Right pane - System monitor
        tmux split-window -h -t $SESSION_NAME
        tmux send-keys -t $SESSION_NAME "btop" Enter
        
        # Bottom pane - Command runner
        tmux select-pane -t $SESSION_NAME:0.0
        tmux split-window -v -t $SESSION_NAME
        tmux send-keys -t $SESSION_NAME "echo 'Command runner pane - execute AI-suggested commands here'" Enter
        
        # Set pane sizes (70/30 horizontal, 70/30 vertical)
        tmux select-layout -t $SESSION_NAME main-vertical
        tmux resize-pane -t $SESSION_NAME:0.1 -x 40
        
        # Focus on main AI pane
        tmux select-pane -t $SESSION_NAME:0.0
      fi
      
      # Attach to session
      tmux attach-session -t $SESSION_NAME
    '')

    # qalarc-explain script - Help system
    (writeShellScriptBin "qalarc-explain" ''
      #!/usr/bin/env bash
      
      show_menu() {
        clear
        echo ""
        echo -e "\033[36m  Qalarc AI-OS Help System\033[0m"
        echo ""
        echo "  What would you like to learn about?"
        echo ""
        echo "  [1] Keyboard shortcuts"
        echo "  [2] AI coding (Claude Code, OpenCode)"
        echo "  [3] Local models (Ollama)"
        echo "  [4] TMUX commands"
        echo "  [5] System snapshots"
        echo "  [6] Installed software"
        echo "  [7] Getting help"
        echo ""
        echo "  [Q] Quit"
        echo ""
        read -p "  Enter selection: " choice
        
        case $choice in
          1) show_keybindings ;;
          2) show_ai_coding ;;
          3) show_ollama ;;
          4) show_tmux ;;
          5) show_snapshots ;;
          6) show_software ;;
          7) show_help ;;
          q|Q) exit 0 ;;
          *) show_menu ;;
        esac
      }
      
      show_keybindings() {
        clear
        echo ""
        echo -e "\033[36m  KEYBOARD SHORTCUTS\033[0m"
        echo ""
        echo "  ESSENTIAL:"
        echo "    Super + Return    Open Ghostty terminal"
        echo "    Meta + Return     Open terminal (alternative)"
        echo "    Super + Shift + S Create snapshot"
        echo ""
        echo "  WINDOW MANAGEMENT (Vim-style tiling):"
        echo "    Meta + T          Toggle tiling mode"
        echo "    Meta + J/K/H/L    Move focus (down/up/left/right)"
        echo "    Meta + Shift + ↑  Move window"
        echo ""
        echo "  TMUX (inside terminal):"
        echo "    Ctrl+a |          Split vertical"
        echo "    Ctrl+a -          Split horizontal"
        echo "    Ctrl+a o          Open Claude Code"
        echo "    Ctrl+a O          Open OpenCode"
        echo "    Alt + arrows      Switch panes"
        echo ""
        read -p "  Press Enter to continue..." 
        show_menu
      }
      
      show_ai_coding() {
        clear
        echo ""
        echo -e "\033[36m  AI CODING ASSISTANTS\033[0m"
        echo ""
        echo "  CLAUDE CODE (Anthropic's AI assistant):"
        echo "    Command: claude"
        echo "    Uses: Claude API (requires internet + API key)"
        echo "    Best for: Complex coding, explanations"
        echo ""
        echo "  OPENCODE (Local alternative):"
        echo "    Command: opencode"
        echo "    Uses: Local Ollama models (100% offline)"
        echo "    Best for: Privacy, no API costs"
        echo ""
        echo "  AI WORKSPACE:"
        echo "    Command: qalarc-ai-workspace"
        echo "    Opens TMUX with AI chat, system monitor, command pane"
        echo ""
        read -p "  Press Enter to continue..."
        show_menu
      }
      
      show_ollama() {
        clear
        echo ""
        echo -e "\033[36m  LOCAL MODELS (OLLAMA)\033[0m"
        echo ""
        echo "  COMMANDS:"
        echo "    ollama list              Show downloaded models"
        echo "    ollama pull <model>      Download a model"
        echo "    ollama run <model>       Start chatting"
        echo "    ollama rm <model>        Delete a model"
        echo ""
        echo "  RECOMMENDED MODELS for 128GB systems:"
        echo "    qwen2.5-coder:32b   18GB  Best for coding"
        echo "    llama3.3:70b        38GB  General purpose"
        echo "    mistral:7b          4GB   Fast responses"
        echo ""
        echo "  EXAMPLE:"
        echo "    ollama pull qwen2.5-coder:32b"
        echo "    ollama run qwen2.5-coder:32b"
        echo ""
        read -p "  Press Enter to continue..."
        show_menu
      }
      
      show_tmux() {
        clear
        echo ""
        echo -e "\033[36m  TMUX COMMANDS\033[0m"
        echo ""
        echo "  PREFIX: Ctrl+a (then release and press next key)"
        echo ""
        echo "  PANES:"
        echo "    Ctrl+a |    Split vertically"
        echo "    Ctrl+a -    Split horizontally"
        echo "    Ctrl+a x    Close current pane"
        echo "    Alt+arrows  Switch between panes"
        echo ""
        echo "  WINDOWS:"
        echo "    Ctrl+a c    New window"
        echo "    Shift+←/→   Switch windows"
        echo ""
        echo "  SESSIONS:"
        echo "    Ctrl+a d    Detach (keeps running)"
        echo "    tmux a      Reattach to session"
        echo ""
        echo "  AI SHORTCUTS:"
        echo "    Ctrl+a o    Open Claude Code in new pane"
        echo "    Ctrl+a O    Open OpenCode in new pane"
        echo ""
        read -p "  Press Enter to continue..."
        show_menu
      }
      
      show_snapshots() {
        clear
        echo ""
        echo -e "\033[36m  SYSTEM SNAPSHOTS\033[0m"
        echo ""
        echo "  Qalarc uses BTRFS snapshots for safety."
        echo "  If something breaks, you can go back in time!"
        echo ""
        echo "  CREATE SNAPSHOT:"
        echo "    Super + Shift + S       (keyboard shortcut)"
        echo "    qalarc-snapshot \"msg\"   (command line)"
        echo "    snapper -c root create  (manual)"
        echo ""
        echo "  LIST SNAPSHOTS:"
        echo "    snapper list"
        echo ""
        echo "  ROLLBACK:"
        echo "    snapper rollback <number>"
        echo "    OR boot from GRUB menu → Snapshots"
        echo ""
        echo "  AUTOMATIC SNAPSHOTS:"
        echo "    - Before every system update"
        echo "    - Hourly (kept for 24h)"
        echo "    - Daily (kept for 1 week)"
        echo ""
        read -p "  Press Enter to continue..."
        show_menu
      }
      
      show_software() {
        clear
        echo ""
        echo -e "\033[36m  INSTALLED SOFTWARE\033[0m"
        echo ""
        echo "  AI/ML:"
        echo "    ollama, claude-code, opencode, pytorch"
        echo ""
        echo "  DEVELOPMENT:"
        echo "    vscode, neovim, git, lazygit"
        echo "    python, nodejs, rust, go"
        echo ""
        echo "  TERMINAL:"
        echo "    ghostty, tmux, btop, htop"
        echo ""
        echo "  BROWSERS:"
        echo "    brave, firefox"
        echo ""
        echo "  MEDIA:"
        echo "    vlc, mpv, ffmpeg"
        echo ""
        echo "  FULL LIST:"
        echo "    See ~/qalarc_OS/ROADMAP/02_SOFTWARE_CATALOG.md"
        echo ""
        read -p "  Press Enter to continue..."
        show_menu
      }
      
      show_help() {
        clear
        echo ""
        echo -e "\033[36m  GETTING HELP\033[0m"
        echo ""
        echo "  COMMANDS:"
        echo "    qalarc-explain      This help system"
        echo "    qalarc-welcome      First-boot wizard"
        echo "    qalarc-system-info  Hardware/software info"
        echo "    man <command>       Manual pages"
        echo "    tldr <command>      Quick examples"
        echo ""
        echo "  DOCUMENTATION:"
        echo "    ~/qalarc_OS/README.md"
        echo "    ~/qalarc_OS/docs/"
        echo "    ~/qalarc_OS/ROADMAP/"
        echo ""
        echo "  ONLINE:"
        echo "    Website: https://qalarc.com"
        echo "    Email:   team@qalarc.com"
        echo ""
        read -p "  Press Enter to continue..."
        show_menu
      }
      
      show_menu
    '')
  ];

  # TMUX Configuration (matching fivelidz setup)
  environment.etc."skel/.tmux.conf".text = ''
    # Tmux Configuration - Optimized for Claude Code usage
    # Qalarc AI-OS Standard Configuration

    # Change prefix to Ctrl+a (easier than Ctrl+b)
    unbind C-b
    set -g prefix C-a
    bind C-a send-prefix

    # Enable mouse support (allows scrolling and pane selection with mouse)
    set -g mouse on

    # Enable scrolling with keyboard
    setw -g mode-keys vi
    bind -n C-k copy-mode

    # Easy split commands (more intuitive)
    bind | split-window -h -c "#{pane_current_path}"
    bind - split-window -v -c "#{pane_current_path}"
    # Even easier: just 'v' for vertical, 'h' for horizontal
    bind v split-window -h -c "#{pane_current_path}"
    bind h split-window -v -c "#{pane_current_path}"
    # Keep original split bindings too
    bind % split-window -h -c "#{pane_current_path}"
    bind '"' split-window -v -c "#{pane_current_path}"

    # Easy pane navigation (Alt + arrow keys, no prefix needed)
    bind -n M-Left select-pane -L
    bind -n M-Right select-pane -R
    bind -n M-Up select-pane -U
    bind -n M-Down select-pane -D

    # Easy window navigation (Shift + arrow keys, no prefix needed)
    bind -n S-Left previous-window
    bind -n S-Right next-window

    # Quick detach (Ctrl+a then Ctrl+d)
    bind C-d detach-client

    # Quick exit from current pane (Ctrl+a then x, no confirmation)
    bind x kill-pane

    # Reload config easily
    bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

    # Better colors - Updated for Ghostty
    set -g default-terminal "xterm-256color"
    set -ag terminal-overrides ",xterm-ghostty:RGB"
    set -as terminal-features ",xterm-ghostty:RGB"

    # Status bar improvements - Qalarc themed
    set -g status-bg "#1d2021"
    set -g status-fg "#ebdbb2"
    set -g status-left-length 40
    set -g status-left '#[fg=#98971a,bold][#S] #[default]'
    set -g status-right '#[fg=#d79921]%H:%M %d-%b-%y #[fg=#458588]| Qalarc AI-OS'

    # Window status
    setw -g window-status-current-style 'fg=#fabd2f,bg=#3c3836,bold'

    # Pane borders - Gruvbox colors
    set -g pane-border-style 'fg=#504945'
    set -g pane-active-border-style 'fg=#98971a'

    # Start window/pane numbering at 1
    set -g base-index 1
    setw -g pane-base-index 1

    # Faster command sequences (less delay)
    set -s escape-time 0

    # Increase scrollback buffer
    set -g history-limit 10000

    # Copy mode improvements (for scrolling)
    bind Enter copy-mode
    bind -T copy-mode-vi v send-keys -X begin-selection
    bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel
    bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-and-cancel

    # Create new window with current path
    bind c new-window -c "#{pane_current_path}"

    # Quick shortcuts for Claude Code
    # Ctrl+a then c+v to open claude in vertical split
    bind C-v split-window -h -c "#{pane_current_path}" "claude"
    # Ctrl+a then c+h to open claude in horizontal split
    bind C-h split-window -v -c "#{pane_current_path}" "claude"
    # Ctrl+a then o to open new pane with claude
    bind o split-window -h -c "#{pane_current_path}" "claude"
    # Ctrl+a then O to open opencode in new pane
    bind O split-window -h -c "#{pane_current_path}" "opencode"

    # Session Saving - tmux-resurrect and tmux-continuum
    # Note: On NixOS, plugins are loaded via programs.tmux or system config
    # These settings configure the plugins when available
    set -g @continuum-restore 'on'
    set -g @continuum-save-interval '15'
    set -g @resurrect-strategy-vim 'session'
  '';

  # Ghostty Configuration
  environment.etc."skel/.config/ghostty/config".text = ''
    # Ghostty Configuration for Qalarc AI-OS
    # https://ghostty.org/docs/config

    # Font settings
    font-family = JetBrains Mono
    font-size = 12

    # Gruvbox Dark theme colors
    background = 1d2021
    foreground = ebdbb2
    
    # Cursor
    cursor-color = fabd2f
    cursor-style = block

    # Selection
    selection-background = 504945
    selection-foreground = ebdbb2

    # Window
    window-padding-x = 8
    window-padding-y = 8

    # Keybindings
    keybind = shift+enter=text:\n
    
    # Performance
    gtk-single-instance = true
  '';

  # Claude Code configuration directory setup
  environment.etc."skel/.claude/settings.json".text = builtins.toJSON {
    permissions = {
      allow = [];
      deny = [];
      ask = [];
      defaultMode = "default";
    };
    alwaysThinkingEnabled = true;
  };

  # ============================================================================
  # "OPEN IN AI" - Right-click context menu for Dolphin file manager
  # ============================================================================
  # This creates a right-click option on folders that opens them in an AI coding
  # assistant (OpenCode) with a model selector dialog.
  
  # Dolphin Service Menu - appears when right-clicking folders
  environment.etc."xdg/kservices5/ServiceMenus/open-in-ai.desktop".text = ''
    [Desktop Entry]
    Type=Service
    ServiceTypes=KonqPopupMenu/Plugin
    MimeType=inode/directory;
    Actions=openInAI;
    X-KDE-Priority=TopLevel
    X-KDE-StartupNotify=false

    [Desktop Action openInAI]
    Name=Open in AI
    Icon=applications-ai
    Exec=qalarc-open-in-ai "%f"
  '';

  # Also install for Plasma 6 location
  environment.etc."xdg/kio/servicemenus/open-in-ai.desktop".text = ''
    [Desktop Entry]
    Type=Service
    MimeType=inode/directory;
    Actions=openInAI;
    X-KDE-Priority=TopLevel
    X-KDE-Submenu=AI Assistant

    [Desktop Action openInAI]
    Name=Open in AI
    Icon=utilities-terminal
    Exec=qalarc-open-in-ai "%f"
  '';

  # Use programs.tmux for proper plugin handling
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      continuum
    ];
  };
}
