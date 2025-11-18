# qalarc_OS Profile: Gaming + AI
# Complete gaming setup with AI tools
# Includes: Steam, Lutris, Heroic, ProtonUp-Qt, PLUS all AI workstation features

{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Allow unfree packages (required for Steam, NVIDIA tools, etc.)
  nixpkgs.config.allowUnfree = true;

  # ═══════════════════════════════════════════════════════════
  # AMD GPU CONFIGURATION
  # ═══════════════════════════════════════════════════════════
  boot.kernelParams = [
    "amdgpu.gpu_recovery=1"
    "amdgpu.ppfeaturemask=0xffffffff"
    "amdgpu.dc=1"
    "amdgpu.dpm=1"
    "mem_sleep_default=deep"
    "amd_pstate=active"
  ];

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=yes
    AllowSuspendThenHibernate=yes
    AllowHybridSleep=no
  '';

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
  # GAMING + AI PACKAGES
  # ═══════════════════════════════════════════════════════════
  environment.systemPackages = with pkgs; [
    # Terminal
    ghostty
    tmux

    # Code Editors
    vscode-fhs
    neovim
    vim

    # Version Control
    git
    git-lfs
    gh
    lazygit

    # Build Tools
    gcc
    clang
    cmake
    gnumake
    ninja

    # Programming Languages
    python312Full
    python312Packages.pipx
    python312Packages.virtualenv
    nodejs_22
    nodePackages.npm
    rustc
    cargo
    go

    # Nix Development
    nil
    nixpkgs-fmt
    alejandra

    # Container Tools
    docker-compose
    ctop
    lazydocker

    # BTRFS Management
    snapper
    compsize

    # AMD GPU Compute (ROCm) - For AI
    rocmPackages.rocm-runtime
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
    rocmPackages.clr
    clinfo

    # AI/ML Tools
    ollama
    oterm
    llama-cpp
    python312Packages.textual
    python312Packages.rich
    python312Packages.transformers
    python312Packages.torch
    open-webui

    # ─────────────────────────────────────────────────────────
    # GAMING SECTION
    # ─────────────────────────────────────────────────────────

    # Game Launchers
    steam
    lutris
    heroic              # Epic Games, GOG launcher

    # Game Management
    protonup-qt         # Manage Proton versions
    gamemode            # Performance optimization
    gamescope           # Gaming compositor

    # Gaming Utilities
    mangohud            # Performance overlay
    goverlay            # MangoHud configurator
    protontricks        # Winetricks for Proton

    # Wine (for non-Steam games)
    wineWowPackages.stable
    winetricks

    # Game Development
    godot_4             # Game engine
    blender             # 3D modeling

    # Discord for gaming communities
    discord

    # ─────────────────────────────────────────────────────────

    # Development Utilities
    direnv
    jq
    ripgrep
    fd
    bat
    eza
    fzf
    zoxide

    # API Development
    postman

    # Debugging
    gdb
    strace

    # Documentation
    man-pages
    tldr

    # System Monitors
    btop
    nvtopPackages.full
    radeontop

    # Hardware Info
    lshw
    pciutils
    usbutils
    lm_sensors

    # Networking
    curl
    wget
    nmap

    # Web Browsers
    brave
    google-chrome

    # Media
    vlc
    mpv

    # Audio
    pavucontrol
    easyeffects

    # Graphics
    gimp
    inkscape
    krita

    # Video Editing & Recording
    kdePackages.kdenlive
    obs-studio
    flameshot

    # File Conversion
    ffmpeg-full

    # Documents
    kdePackages.okular
    libreoffice-qt6

    # KDE Apps
    kdePackages.kate
    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.spectacle
    kdePackages.filelight
    kdePackages.kdeconnect-kde

    # Hardware Acceleration
    libva
    libva-utils
    vulkan-tools
  ];

  # ═══════════════════════════════════════════════════════════
  # GAMING-SPECIFIC CONFIGURATION
  # ═══════════════════════════════════════════════════════════

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # GameMode for performance optimization
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
  };

  # ═══════════════════════════════════════════════════════════
  # PROGRAMS
  # ═══════════════════════════════════════════════════════════

  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.tmux.enable = true;
  programs.kdeconnect.enable = true;

  # ═══════════════════════════════════════════════════════════
  # SERVICES
  # ═══════════════════════════════════════════════════════════

  services.printing.enable = true;
  services.tailscale.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish.enable = true;
  };

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
      TIMELINE_LIMIT_HOURLY = "10";
      TIMELINE_LIMIT_DAILY = "7";
      TIMELINE_LIMIT_WEEKLY = "4";
      SPACE_LIMIT = "0.5";
      FREE_LIMIT = "0.2";
    };
  };

  # Ollama for AI
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    environmentVariables = {
      OLLAMA_NUM_GPU = "999";
      OLLAMA_MODELS = "/home/{{USERNAME}}/Models/ollama";
    };
  };

  # Open WebUI
  services.open-webui = {
    enable = true;
    host = "127.0.0.1";
    port = 8080;
  };

  # ═══════════════════════════════════════════════════════════
  # VIRTUALIZATION
  # ═══════════════════════════════════════════════════════════

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    autoPrune.enable = true;
  };

  # ═══════════════════════════════════════════════════════════
  # FONTS
  # ═══════════════════════════════════════════════════════════

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      jetbrains-mono
      fira-code
      nerd-fonts.jetbrains-mono
    ];
  };

  # ═══════════════════════════════════════════════════════════
  # HARDWARE ACCELERATION
  # ═══════════════════════════════════════════════════════════

  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Important for 32-bit games
    extraPackages = with pkgs; [
      libva
      vaapiVdpau
      rocmPackages.clr.icd
    ];
  };

  # Enable Steam hardware decoding
  hardware.steam-hardware.enable = true;

  # ═══════════════════════════════════════════════════════════
  # NETWORKING
  # ═══════════════════════════════════════════════════════════

  networking.hostName = "{{HOSTNAME}}";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 8080 ];
    allowedUDPPorts = [
      27000 27015 27031 27036  # Steam in-home streaming
    ];
    checkReversePath = "loose";
  };

  # ═══════════════════════════════════════════════════════════
  # SYSTEM CONFIGURATION
  # ═══════════════════════════════════════════════════════════

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "America/New_York";

  environment.sessionVariables = {
    HF_HOME = "/home/{{USERNAME}}/Models/huggingface";
    OLLAMA_MODELS = "/home/{{USERNAME}}/Models/ollama";
    # Gaming optimizations
    MANGOHUD = "1";
    AMD_VULKAN_ICD = "RADV";
  };

  users.users.{{USERNAME}} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "docker" "render" "gamemode" ];
  };

  system.stateVersion = "25.05";
}
