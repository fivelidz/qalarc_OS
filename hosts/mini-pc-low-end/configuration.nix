{ config, pkgs, lib, ... }:

{
  # Low-End Mini PC Configuration
  # For systems with 8GB RAM, 256GB storage
  # Can serve as: standalone workstation, server, or assistant to main AI system
  
  # System identification
  networking.hostName = "qalarc-mini";
  system.stateVersion = "25.05";

  # Boot configuration - optimized for low memory
  boot = {
    # Use CachyOS kernel for performance on limited hardware
    kernelPackages = pkgs.linuxPackages_latest; # CachyOS needs source build
    
    # Boot loader - systemd-boot is lighter than GRUB
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Minimal kernel parameters
    kernelParams = [
      "mitigations=off"  # Disable CPU mitigations for performance (optional, security tradeoff)
    ];

    # Minimal initrd
    initrd.kernelModules = [ ];
  };

  # Time and locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # User account
  users.users.qalarc = {
    isNormalUser = true;
    description = "QALARC User";
    extraGroups = [ "wheel" "networkmanager" "docker" "video" ];
    initialPassword = "qalarc";  # Change on first login!
  };

  # Nix settings - conservative for low storage
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      max-jobs = 4;  # Limit parallel jobs for low RAM
    };
    gc = {
      automatic = true;
      dates = "daily";  # More aggressive GC
      options = "--delete-older-than 7d";  # Keep only 7 days
    };
  };

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

  # Networking
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];  # SSH only by default
  };

  # SSH server
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # Minimal desktop environment - choose ONE:
  
  # Option A: KDE Plasma (full desktop, ~1.5GB RAM usage)
  # services.xserver.enable = true;
  # services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;
  
  # Option B: XFCE (lighter, ~800MB RAM usage) - RECOMMENDED for 8GB
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager.lightdm.enable = true;  # LightDM is under xserver in 25.05
  };

  # Option C: Server mode (no desktop, SSH only)
  # Uncomment above and comment out desktop options
  # services.xserver.enable = false;

  # Essential packages only
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim
    git
    wget
    curl
    htop
    
    # Network tools
    nmap
    iperf3
    
    # Containers (for running services)
    docker-compose
    
    # Terminal browser (for server mode)
    w3m
    
    # File management
    mc  # Midnight Commander
    
    # System info
    neofetch
    lshw
  ];

  # Docker for containerized services
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    # Limit Docker resources
    daemon.settings = {
      "storage-driver" = "overlay2";
    };
  };

  # Tailscale for remote access
  services.tailscale.enable = true;

  # ZRAM swap (use compressed RAM as swap - critical for 8GB systems)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;  # Use 50% of RAM for ZRAM (effective 12GB with compression)
  };

  # Disable heavy services
  services.printing.enable = false;
  services.avahi.enable = false;
  
  # Enable sudo without password for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Use cases for this profile:
  # 1. Home server: Docker containers, Tailscale, SSH access
  # 2. Development workstation: Light coding, git, containers
  # 3. Network node: Distributed compute assistant to main AI system
  # 4. Media server: Jellyfin, Plex via Docker
  # 5. Backup target: rsync destination for main system
}
