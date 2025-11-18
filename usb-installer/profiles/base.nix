# qalarc_OS Profile: Base System
# Minimal installation with core utilities
# For custom builds or server deployments

{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nixpkgs.config.allowUnfree = true;

  # ═══════════════════════════════════════════════════════════
  # AMD GPU CONFIGURATION
  # ═══════════════════════════════════════════════════════════
  boot.kernelParams = [
    "amdgpu.gpu_recovery=1"
    "amdgpu.dc=1"
    "mem_sleep_default=deep"
  ];

  # ═══════════════════════════════════════════════════════════
  # DESKTOP ENVIRONMENT - KDE Plasma 6
  # ═══════════════════════════════════════════════════════════
  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
  };

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # ═══════════════════════════════════════════════════════════
  # BASE SYSTEM PACKAGES (Minimal)
  # ═══════════════════════════════════════════════════════════
  environment.systemPackages = with pkgs; [
    # Terminal
    ghostty
    tmux

    # Editor
    neovim
    vim

    # Version Control
    git
    gh

    # Build Tools
    gcc
    cmake
    gnumake

    # Languages
    python312Full
    nodejs_22

    # Nix Tools
    nil
    nixpkgs-fmt

    # BTRFS Management
    snapper
    compsize

    # Core Utilities
    curl
    wget
    jq
    ripgrep
    fd
    bat
    eza
    fzf

    # System Info
    htop
    btop
    lshw
    pciutils
    usbutils

    # Networking
    traceroute
    nmap

    # Browser
    brave

    # Media
    vlc

    # Documents
    kdePackages.okular

    # KDE Essentials
    kdePackages.kate
    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.spectacle

    # Hardware Acceleration
    libva
    vulkan-tools
  ];

  # ═══════════════════════════════════════════════════════════
  # PROGRAMS
  # ═══════════════════════════════════════════════════════════

  programs.git.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.tmux.enable = true;

  # ═══════════════════════════════════════════════════════════
  # SERVICES
  # ═══════════════════════════════════════════════════════════

  services.printing.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # BTRFS Snapshots
  services.snapper = {
    snapshotRootOnBoot = true;
    configs.root = {
      SUBVOLUME = "/";
      ALLOW_USERS = [ "{{USERNAME}}" ];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_MIN_AGE = "1800";
      TIMELINE_LIMIT_HOURLY = "5";
      TIMELINE_LIMIT_DAILY = "7";
      TIMELINE_LIMIT_WEEKLY = "2";
      SPACE_LIMIT = "0.3";
    };
  };

  # ═══════════════════════════════════════════════════════════
  # FONTS
  # ═══════════════════════════════════════════════════════════

  fonts = {
    packages = with pkgs; [
      noto-fonts
      jetbrains-mono
      nerd-fonts.jetbrains-mono
    ];
  };

  # ═══════════════════════════════════════════════════════════
  # HARDWARE ACCELERATION
  # ═══════════════════════════════════════════════════════════

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libva
      vaapiVdpau
    ];
  };

  # ═══════════════════════════════════════════════════════════
  # NETWORKING
  # ═══════════════════════════════════════════════════════════

  networking.hostName = "{{HOSTNAME}}";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # ═══════════════════════════════════════════════════════════
  # SYSTEM CONFIGURATION
  # ═══════════════════════════════════════════════════════════

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "America/New_York";

  users.users.{{USERNAME}} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
  };

  system.stateVersion = "25.05";
}
