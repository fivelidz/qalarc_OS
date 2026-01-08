{ config, pkgs, lib, ... }:

{
  imports = [
    ./setup-wizard.nix  # Comprehensive onboarding experience
    ./themes.nix        # macOS/Windows/Tiling theme switcher
  ];

  # Qalarc AI-OS Branding Module
  # Installs wallpapers, welcome wizard, and branding assets

  # Copy wallpapers to system location
  environment.etc = {
    "qalarc/wallpapers/qalarc_branded_dark.png".source = ../../wallpapers/qalarc_branded_dark.png;
    "qalarc/wallpapers/qalarc_branded_neural.png".source = ../../wallpapers/qalarc_branded_neural.png;
    "qalarc/wallpapers/qalarc_branded_minimal.png".source = ../../wallpapers/qalarc_branded_minimal.png;
    "qalarc/wallpapers/qalarc_branded_tech.png".source = ../../wallpapers/qalarc_branded_tech.png;
    "qalarc/wallpapers/qalarc_branded_gradient.png".source = ../../wallpapers/qalarc_branded_gradient.png;
    "qalarc/wallpapers/qalarc_branded_circuit.png".source = ../../wallpapers/qalarc_branded_circuit.png;
    "qalarc/wallpapers/qalarc_chip_abstract.png".source = ../../wallpapers/qalarc_chip_abstract.png;
    "qalarc/wallpapers/qalarc_data_center.png".source = ../../wallpapers/qalarc_data_center.png;
    "qalarc/wallpapers/qalarc_neural_network.png".source = ../../wallpapers/qalarc_neural_network.png;
    "qalarc/wallpapers/qalarc_welcome_dark.png".source = ../../wallpapers/qalarc_welcome_dark.png;
  };

  # Symlink wallpapers to standard location for easy access
  systemd.tmpfiles.rules = [
    "L+ /usr/share/wallpapers/qalarc - - - - /etc/qalarc/wallpapers"
  ];

  environment.systemPackages = with pkgs; [
    # Welcome wizard script
    (writeShellScriptBin "qalarc-welcome" ''
      #!/usr/bin/env bash
      
      # Qalarc AI-OS Welcome Wizard
      # Runs on first boot to guide users through setup
      
      WALLPAPER_DIR="/etc/qalarc/wallpapers"
      
      clear
      echo ""
      echo -e "\033[36m"
      cat << 'BANNER'
       ██████╗  █████╗ ██╗      █████╗ ██████╗  ██████╗
      ██╔═══██╗██╔══██╗██║     ██╔══██╗██╔══██╗██╔════╝
      ██║   ██║███████║██║     ███████║██████╔╝██║     
      ██║▄▄ ██║██╔══██║██║     ██╔══██║██╔══██╗██║     
      ╚██████╔╝██║  ██║███████╗██║  ██║██║  ██║╚██████╗
       ╚══▀▀═╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝
                                                        
                      A I - O S
      BANNER
      echo -e "\033[0m"
      echo ""
      echo -e "\033[1;37m  Welcome to Qalarc AI-OS!\033[0m"
      echo ""
      echo "  Your pre-configured operating system for local AI."
      echo ""
      echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
      echo ""
      
      # System info
      echo -e "\033[1;33m  SYSTEM INFORMATION\033[0m"
      echo ""
      echo "  Hostname:    $(hostname)"
      echo "  Kernel:      $(uname -r)"
      echo "  Memory:      $(free -h | awk '/^Mem:/{print $2}') total"
      echo "  CPU:         $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)"
      echo ""
      
      # GPU info if available
      if command -v lspci &> /dev/null; then
        GPU=$(lspci | grep -i 'vga\|3d\|display' | head -1 | cut -d: -f3 | xargs)
        if [ -n "$GPU" ]; then
          echo "  GPU:         $GPU"
          echo ""
        fi
      fi
      
      echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
      echo ""
      echo -e "\033[1;33m  QUICK START GUIDE\033[0m"
      echo ""
      echo "  1. \033[1mSet your wallpaper\033[0m"
      echo "     Qalarc wallpapers are in: $WALLPAPER_DIR"
      echo "     Or run: qalarc-set-wallpaper"
      echo ""
      echo "  2. \033[1mConnect to the internet\033[0m"
      echo "     WiFi: Click network icon in taskbar"
      echo "     Check: ping 8.8.8.8"
      echo ""
      echo "  3. \033[1mStart using AI\033[0m"
      echo "     Run: ollama run llama3.2"
      echo "     Or:  qalarc-ai-workspace"
      echo ""
      echo "  4. \033[1mAccess remotely\033[0m"
      echo "     SSH: ssh $(whoami)@$(hostname -I | awk '{print $1}')"
      echo "     Tailscale: sudo tailscale up"
      echo ""
      echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
      echo ""
      echo -e "\033[1;33m  AVAILABLE COMMANDS\033[0m"
      echo ""
      echo "  qalarc-welcome        - Show this welcome screen"
      echo "  qalarc-set-wallpaper  - Choose a Qalarc wallpaper"
      echo "  qalarc-ai-workspace   - Launch AI workspace"
      echo "  qalarc-system-info    - Show detailed system info"
      echo "  qalarc-vpn-status     - Check VPN connections"
      echo ""
      echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
      echo ""
      echo -e "\033[1;33m  RESOURCES\033[0m"
      echo ""
      echo "  Website:     https://qalarc.com"
      echo "  Support:     team@qalarc.com"
      echo "  Docs:        ~/qalarc_OS/README.md"
      echo ""
      echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
      echo ""
      echo "  Press Enter to continue..."
      read
    '')

    # Wallpaper selector script
    (writeShellScriptBin "qalarc-set-wallpaper" ''
      #!/usr/bin/env bash
      
      WALLPAPER_DIR="/etc/qalarc/wallpapers"
      
      echo ""
      echo -e "\033[36m  Qalarc Wallpaper Selector\033[0m"
      echo ""
      
      # List available wallpapers
      echo "  Available wallpapers:"
      echo ""
      
      i=1
      declare -a wallpapers
      for wp in "$WALLPAPER_DIR"/*.png; do
        name=$(basename "$wp" .png)
        echo "    $i) $name"
        wallpapers[$i]="$wp"
        ((i++))
      done
      
      echo ""
      read -p "  Select wallpaper (1-$((i-1))): " choice
      
      if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -lt "$i" ]; then
        selected="''${wallpapers[$choice]}"
        
        # Try to set wallpaper based on desktop environment
        if [ "$XDG_CURRENT_DESKTOP" = "KDE" ] || command -v plasma-apply-wallpaperimage &> /dev/null; then
          echo "  Setting KDE Plasma wallpaper..."
          plasma-apply-wallpaperimage "$selected" 2>/dev/null || \
          qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
            var allDesktops = desktops();
            for (var i = 0; i < allDesktops.length; i++) {
              var d = allDesktops[i];
              d.wallpaperPlugin = 'org.kde.image';
              d.currentConfigGroup = ['Wallpaper', 'org.kde.image', 'General'];
              d.writeConfig('Image', 'file://$selected');
            }
          "
        elif command -v gsettings &> /dev/null; then
          echo "  Setting GNOME/GTK wallpaper..."
          gsettings set org.gnome.desktop.background picture-uri "file://$selected"
          gsettings set org.gnome.desktop.background picture-uri-dark "file://$selected"
        elif command -v xfconf-query &> /dev/null; then
          echo "  Setting XFCE wallpaper..."
          xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "$selected"
        elif command -v feh &> /dev/null; then
          echo "  Setting wallpaper with feh..."
          feh --bg-fill "$selected"
        else
          echo "  Could not auto-set wallpaper."
          echo "  Please set manually: $selected"
        fi
        
        echo ""
        echo -e "\033[32m  Wallpaper set to: $(basename "$selected")\033[0m"
      else
        echo "  Invalid selection."
      fi
      echo ""
    '')

    # System info script
    (writeShellScriptBin "qalarc-system-info" ''
      #!/usr/bin/env bash
      
      echo ""
      echo -e "\033[36m╔════════════════════════════════════════════════════════════╗\033[0m"
      echo -e "\033[36m║             Qalarc AI-OS System Information                ║\033[0m"
      echo -e "\033[36m╚════════════════════════════════════════════════════════════╝\033[0m"
      echo ""
      
      echo -e "\033[1;33m  HARDWARE\033[0m"
      echo "  ─────────────────────────────────────────"
      echo "  CPU:        $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)"
      echo "  Cores:      $(nproc) cores"
      echo "  Memory:     $(free -h | awk '/^Mem:/{print $3 " / " $2}')"
      echo "  Swap:       $(free -h | awk '/^Swap:/{print $3 " / " $2}')"
      
      if command -v lspci &> /dev/null; then
        GPU=$(lspci | grep -i 'vga\|3d\|display' | head -1 | cut -d: -f3 | xargs)
        [ -n "$GPU" ] && echo "  GPU:        $GPU"
      fi
      echo ""
      
      echo -e "\033[1;33m  STORAGE\033[0m"
      echo "  ─────────────────────────────────────────"
      df -h / /home /nix 2>/dev/null | awk 'NR>1{printf "  %-10s %s / %s (%s used)\n", $6, $3, $2, $5}'
      echo ""
      
      echo -e "\033[1;33m  NETWORK\033[0m"
      echo "  ─────────────────────────────────────────"
      echo "  Hostname:   $(hostname)"
      ip -4 addr show | grep -oP 'inet \K[\d.]+' | grep -v '127.0.0.1' | while read ip; do
        echo "  IP:         $ip"
      done
      echo ""
      
      echo -e "\033[1;33m  SERVICES\033[0m"
      echo "  ─────────────────────────────────────────"
      for svc in sshd ollama tailscaled docker; do
        status=$(systemctl is-active $svc 2>/dev/null || echo "not installed")
        if [ "$status" = "active" ]; then
          echo -e "  $svc: \033[32m●\033[0m running"
        else
          echo -e "  $svc: \033[31m○\033[0m $status"
        fi
      done
      echo ""
      
      echo -e "\033[1;33m  AI MODELS\033[0m"
      echo "  ─────────────────────────────────────────"
      if command -v ollama &> /dev/null && systemctl is-active ollama &>/dev/null; then
        ollama list 2>/dev/null | head -5 || echo "  No models installed"
      else
        echo "  Ollama not running"
      fi
      echo ""
    '')
  ];

  # First-boot welcome service (shows terminal welcome on first login)
  # Users can run qalarc-welcome anytime to see it again
}
