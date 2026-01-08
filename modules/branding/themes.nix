{ config, pkgs, lib, ... }:

{
  # Qalarc AI-OS Theme Application Module
  # Applies desktop themes: macOS-like, Windows-like, Qalarc Dark, Tiling
  
  environment.systemPackages = with pkgs; [
    # Theme application script
    (writeShellScriptBin "qalarc-apply-theme" ''
      #!/usr/bin/env bash
      
      # Colors
      CYAN='\033[38;2;74;159;184m'
      ORANGE='\033[38;2;204;85;40m'
      GREEN='\033[38;2;51;204;119m'
      NC='\033[0m'
      
      THEME="''${1:-qalarc-dark}"
      CONFIG_DIR="$HOME/.config"
      
      echo ""
      echo -e "''${CYAN}Applying theme: ''${ORANGE}$THEME''${NC}"
      echo ""
      
      case "$THEME" in
        qalarc-dark|qalarc)
          echo "Setting up Qalarc Dark theme (NERV-inspired)..."
          
          # Set wallpaper
          plasma-apply-wallpaperimage /etc/qalarc/wallpapers/qalarc_branded_dark.png 2>/dev/null
          
          # Set color scheme to dark
          plasma-apply-colorscheme BreezeDark 2>/dev/null
          
          # Set to Breeze Dark with modifications
          kwriteconfig6 --file kdeglobals --group General --key ColorScheme "BreezeDark"
          kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage "org.kde.breezedark.desktop"
          
          echo -e "''${GREEN}✓''${NC} Qalarc Dark theme applied"
          echo "  - Dark color scheme"
          echo "  - Qalarc branded wallpaper"
          echo "  - Cyan/Orange accents"
          ;;
          
        macos-like|macos|mac)
          echo "Setting up macOS-like theme..."
          
          # Panel at top (global menu bar style)
          # Note: User may need to manually move panel to top
          
          # Install and apply Latte Dock if available
          if command -v latte-dock &> /dev/null; then
            echo "  Configuring Latte Dock..."
            # Kill existing
            killall latte-dock 2>/dev/null
            sleep 1
            # Start with macOS preset
            latte-dock --layout Unity &
          else
            echo "  Note: Install latte-dock for full macOS experience"
            echo "  Run: sudo nix-env -iA nixos.latte-dock"
          fi
          
          # Set Kvantum theme (WhiteSur or similar)
          if [ -d "/usr/share/Kvantum/WhiteSur" ]; then
            kvantummanager --set WhiteSur 2>/dev/null
          fi
          
          # Global menu
          kwriteconfig6 --file kwinrc --group Windows --key BorderlessMaximizedWindows true
          
          # Window decorations - less visible buttons, rounded
          kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft "XIA"
          kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight ""
          
          # Reconfigure KWin
          qdbus org.kde.KWin /KWin reconfigure 2>/dev/null
          
          echo -e "''${GREEN}✓''${NC} macOS-like theme applied"
          echo "  - Window buttons on left"
          echo "  - Consider moving panel to top manually"
          echo "  - Install WhiteSur-gtk-theme for full experience"
          ;;
          
        windows-like|windows|win)
          echo "Setting up Windows-like theme..."
          
          # Panel at bottom (default)
          # Taskbar style
          
          # Set window buttons on right
          kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft ""
          kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight "IAX"
          
          # Traditional task manager
          # Note: Panel configuration is complex, give instructions
          
          # Light or dark based on preference
          echo "  Choose variant:"
          echo "    1) Windows 11 Dark"
          echo "    2) Windows 11 Light"
          read -p "  Select [1/2]: " win_variant
          
          case "$win_variant" in
            2)
              plasma-apply-colorscheme BreezeLight 2>/dev/null
              ;;
            *)
              plasma-apply-colorscheme BreezeDark 2>/dev/null
              ;;
          esac
          
          # Reconfigure KWin
          qdbus org.kde.KWin /KWin reconfigure 2>/dev/null
          
          echo -e "''${GREEN}✓''${NC} Windows-like theme applied"
          echo "  - Window buttons on right"
          echo "  - Bottom panel (default)"
          echo "  - Consider installing Win11OS-dark from KDE Store"
          ;;
          
        tiling|i3|bspwm)
          echo "Setting up Tiling window manager style..."
          
          # Enable KWin tiling scripts
          # Krohnkite or Bismuth
          
          if kpackagetool6 --list | grep -q krohnkite; then
            kwriteconfig6 --file kwinrc --group Plugins --key krohnkiteEnabled true
            echo "  Enabled Krohnkite tiling"
          elif kpackagetool6 --list | grep -q bismuth; then
            kwriteconfig6 --file kwinrc --group Plugins --key bismuthEnabled true
            echo "  Enabled Bismuth tiling"
          else
            echo "  Note: Install Krohnkite for tiling"
            echo "  System Settings > Window Management > KWin Scripts > Get New Scripts"
          fi
          
          # Dark theme works best with tiling
          plasma-apply-colorscheme BreezeDark 2>/dev/null
          
          # Reduce window decorations
          kwriteconfig6 --file kwinrc --group Windows --key BorderlessMaximizedWindows true
          
          # Reconfigure
          qdbus org.kde.KWin /KWin reconfigure 2>/dev/null
          
          echo -e "''${GREEN}✓''${NC} Tiling mode configured"
          echo ""
          echo "  Keyboard shortcuts (Krohnkite):"
          echo "    Meta+Enter  - Open terminal"
          echo "    Meta+J/K    - Focus next/prev window"
          echo "    Meta+H/L    - Shrink/grow window"
          echo "    Meta+Shift+J/K - Move window"
          echo "    Meta+F      - Toggle float"
          echo "    Meta+M      - Toggle monocle"
          ;;
          
        server|minimal|headless)
          echo "Server mode - no desktop changes needed"
          echo "SSH access: ssh $(whoami)@$(hostname -I | awk '{print $1}')"
          ;;
          
        *)
          echo "Unknown theme: $THEME"
          echo ""
          echo "Available themes:"
          echo "  qalarc-dark  - Cyan/Orange sci-fi (default)"
          echo "  macos-like   - macOS style dock and layout"
          echo "  windows-like - Windows 11 style taskbar"
          echo "  tiling       - i3/bspwm style keyboard-driven"
          echo "  server       - No GUI, SSH only"
          exit 1
          ;;
      esac
      
      echo ""
      echo -e "''${CYAN}Theme applied! You may need to log out and back in for full effect.''${NC}"
      echo ""
    '')
    
    # Quick theme switcher for KDE
    (writeShellScriptBin "qalarc-theme-menu" ''
      #!/usr/bin/env bash
      
      echo ""
      echo "╔═══════════════════════════════════════╗"
      echo "║     Qalarc Theme Selector             ║"
      echo "╚═══════════════════════════════════════╝"
      echo ""
      echo "  1) Qalarc Dark (sci-fi, cyan/orange)"
      echo "  2) macOS-like (dock, global menu)"
      echo "  3) Windows-like (taskbar, start menu)"
      echo "  4) Tiling (keyboard-driven)"
      echo ""
      read -p "  Select theme [1-4]: " choice
      
      case $choice in
        1) qalarc-apply-theme qalarc-dark ;;
        2) qalarc-apply-theme macos-like ;;
        3) qalarc-apply-theme windows-like ;;
        4) qalarc-apply-theme tiling ;;
        *) echo "Invalid choice" ;;
      esac
    '')
  ];
}
