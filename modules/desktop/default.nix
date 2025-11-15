{ config, pkgs, lib, ... }:

{
  # Enable X11 and Wayland support
  services.xserver = {
    enable = true;

    # AMD GPU driver
    videoDrivers = [ "amdgpu" ];

    # Enable libinput for touchpad support (if using laptop)
    libinput.enable = true;
  };

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

    # Tiling extension for KWin (Krohnkite for Plasma 6)
    kdePackages.krohnkite

    # Additional window management tools
    kdePackages.kwin-bismuth  # Alternative tiling (if available)
  ];

  # KDE Connect (firewall rules for phone integration)
  programs.kdeconnect.enable = true;

  # Enable CUPS for printing
  services.printing.enable = true;

  # Font configuration for better readability
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      jetbrains-mono
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Hack" ]; })
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
