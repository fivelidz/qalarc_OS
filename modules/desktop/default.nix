{ config, pkgs, lib, ... }:

{
  # Enable X11 and Wayland support
  services.xserver = {
    enable = true;

    # AMD GPU driver
    videoDrivers = [ "amdgpu" ];
  };

  # Enable libinput for touchpad/mouse support
  services.libinput.enable = true;

  # Display manager (SDDM for KDE)
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;  # Enable Wayland support
    };
  };

  # KDE Plasma 6
  services.desktopManager.plasma6.enable = true;

  # KDE applications and utilities
  environment.systemPackages = with pkgs; [
    # KDE Applications
    kdePackages.kate
    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.spectacle  # Screenshots
    kdePackages.filelight  # Disk usage analyzer
    kdePackages.kwalletmanager
    kdePackages.kdeconnect-kde  # Phone integration

    # Communication
    signal-desktop  # Secure messaging

    # Tiling extension for KWin (Krohnkite for Plasma 6)
    # Note: kdePackages.krohnkite and kwin-bismuth may not be packaged in 25.05
    # Users can install manually via KWin Scripts in System Settings
  ];

  # ============================================================================
  # KEYBOARD SHORTCUTS - Qalarc defaults
  # ============================================================================
  # These are set via KDE's kglobalshortcutsrc file in the skeleton directory
  
  # Global shortcuts for new users
  environment.etc."skel/.config/kglobalshortcutsrc".text = ''
    [ghostty.desktop]
    _k_friendly_name=Ghostty Terminal
    _launch=Meta+Return,none,Ghostty Terminal

    [qalarc-ai-quick.desktop]
    _k_friendly_name=Quick AI Access
    _launch=Meta+A,none,Quick AI Access

    [org.kde.spectacle.desktop]
    _k_friendly_name=Spectacle
    RectangularRegionScreenShot=Meta+Shift+S,Meta+Shift+Print,Capture Rectangular Region

    [kwin]
    Window Close=Meta+Q,Alt+F4,Close Window
    Window Maximize=Meta+Up,Meta+PgUp,Maximize Window
    Window Minimize=Meta+Down,Meta+PgDown,Minimize Window
  '';

  # Desktop entries for shortcut targets
  environment.etc."xdg/applications/ghostty-shortcut.desktop".text = ''
    [Desktop Entry]
    Name=Ghostty Terminal
    Comment=Open Ghostty terminal
    Exec=ghostty
    Icon=utilities-terminal
    Terminal=false
    Type=Application
    Categories=System;TerminalEmulator;
    Keywords=terminal;console;command line;
  '';

  environment.etc."xdg/applications/qalarc-ai-quick.desktop".text = ''
    [Desktop Entry]
    Name=Quick AI Access
    Comment=Launch AI assistant quickly
    Exec=qalarc-ai-quick
    Icon=applications-ai
    Terminal=false
    Type=Application
    Categories=Development;AI;
    Keywords=ai;code;assistant;opencode;claude;
  '';

  # KDE Connect (firewall rules for phone integration)
  programs.kdeconnect.enable = true;

  # Enable CUPS for printing
  services.printing.enable = true;

  # Font configuration for better readability
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans  # renamed from noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrains Mono" "Fira Code" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
    };
  };

  # Tiling keyboard shortcuts (configured via KDE settings)
  # Users can access Krohnkite settings through:
  # System Settings > Window Management > KWin Scripts > Krohnkite

  # Default tiling shortcuts (can be customized):
  # Meta+T: Toggle tiling mode
  # Meta+Shift+T: Toggle tiling for current window
  # Meta+J/K/H/L: Navigate windows (vim-style)
  # Meta+Shift+J/K/H/L: Move windows
  # Meta+I/D: Increase/decrease master area

  # CLI AI assistant note:
  # KDE configuration can be queried/modified via:
  # - kreadconfig6 / kwriteconfig6 commands
  # - dbus-send to org.kde.* services
  # - Reading ~/.config/kwinrc and other config files

  # Example for AI assistant to read KDE settings:
  # kreadconfig6 --file kwinrc --group Plugins --key krohnkiteEnabled
}
