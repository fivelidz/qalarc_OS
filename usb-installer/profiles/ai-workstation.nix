# qalarc_OS Profile: AI Workstation (Recommended)
# Optimized for AI development, ML research, and large language models
# Includes: ROCm, Ollama, Python ML stack, Terminal UI tools

{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Allow unfree packages (VSCode, Chrome, etc.)
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
  # AI WORKSTATION PACKAGES
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
    nodePackages.pnpm
    rustc
    cargo
    go

    # Nix Development
    nil
    nixpkgs-fmt
    nixd
    alejandra

    # Container Tools
    docker-compose
    podman-compose
    ctop
    dive
    lazydocker

    # BTRFS Management
    snapper
    compsize

    # AMD GPU Compute (ROCm) - CRITICAL FOR AI
    rocmPackages.rocm-runtime
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
    rocmPackages.clr
    clinfo

    # AI/ML Tools - WORKSTATION CORE
    ollama                        # Local LLM server
    oterm                         # Terminal UI for Ollama
    llama-cpp                     # GGUF model inference

    # Python ML Stack
    python312Packages.textual     # TUI framework
    python312Packages.rich        # Terminal formatting
    python312Packages.transformers # HuggingFace models
    python312Packages.torch       # PyTorch

    # Open WebUI - Web interface for models
    open-webui

    # Development Utilities
    direnv
    jq
    yq-go
    ripgrep
    fd
    bat
    eza
    fzf
    zoxide

    # API Development
    postman
    insomnia

    # Database Tools
    dbeaver-bin

    # Debugging
    gdb
    valgrind
    strace
    linuxPackages.perf

    # Documentation
    man-pages
    tldr

    # System Monitors
    btop
    htop
    nvtopPackages.full
    radeontop

    # Hardware Info
    lshw
    pciutils
    usbutils
    lm_sensors
    smartmontools

    # Networking
    curl
    wget
    nmap
    traceroute

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

    # Video Editing
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
    configure = {
      customRC = ''
        set number
        set relativenumber
        set tabstop=2
        set shiftwidth=2
        set expandtab
        syntax on
      '';
    };
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    terminal = "screen-256color";
    extraConfig = ''
      set -g mouse on
      set -g history-limit 10000
    '';
  };

  programs.kdeconnect.enable = true;

  # ═══════════════════════════════════════════════════════════
  # SERVICES
  # ═══════════════════════════════════════════════════════════

  services.printing.enable = true;
  services.tailscale.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      userServices = true;
      workstation = true;
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = true;
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
      TIMELINE_LIMIT_MONTHLY = "3";
      TIMELINE_LIMIT_YEARLY = "0";
      SPACE_LIMIT = "0.5";
      FREE_LIMIT = "0.2";
    };
  };

  # Ollama Service - AI Workstation Core
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    environmentVariables = {
      OLLAMA_NUM_GPU = "999";
      OLLAMA_DEBUG = "0";
      OLLAMA_MODELS = "/home/{{USERNAME}}/Models/ollama";
    };
  };

  # Open WebUI Service
  services.open-webui = {
    enable = true;
    host = "127.0.0.1";
    port = 8080;
    environment = {
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
    };
  };

  # ═══════════════════════════════════════════════════════════
  # VIRTUALIZATION - Docker
  # ═══════════════════════════════════════════════════════════

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
    daemon.settings = {
      features = { buildkit = true; };
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "3";
      };
    };
  };

  systemd.services.docker.serviceConfig = {
    LimitNOFILE = 1048576;
    LimitNPROC = 1048576;
  };

  # ═══════════════════════════════════════════════════════════
  # FONTS
  # ═══════════════════════════════════════════════════════════

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      jetbrains-mono
      fira-code
      nerd-fonts.fira-code nerd-fonts.jetbrains-mono
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

  # ═══════════════════════════════════════════════════════════
  # HARDWARE ACCELERATION (AMD)
  # ═══════════════════════════════════════════════════════════

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva
      libvdpau-va-gl
      vaapiVdpau
      rocmPackages.clr.icd
    ];
  };

  # ═══════════════════════════════════════════════════════════
  # NETWORKING
  # ═══════════════════════════════════════════════════════════

  networking.hostName = "{{HOSTNAME}}";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 8080 ];  # SSH, Open WebUI
    checkReversePath = "loose";
  };

  # ═══════════════════════════════════════════════════════════
  # SYSTEM CONFIGURATION
  # ═══════════════════════════════════════════════════════════

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "America/New_York";

  # AI Model Storage Paths
  environment.sessionVariables = {
    HF_HOME = "/home/{{USERNAME}}/Models/huggingface";
    OLLAMA_MODELS = "/home/{{USERNAME}}/Models/ollama";
  };

  users.users.{{USERNAME}} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "docker" "render" ];
  };

  system.stateVersion = "25.05";
}
