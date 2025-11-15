{ config, pkgs, lib, inputs, ... }:

{
  # System identification
  networking.hostName = "gmktec-01";
  system.stateVersion = "25.05"; # Don't change this after installation

  # Boot configuration
  boot = {
    # Use CachyOS kernel from Chaotic-Nyx for performance
    kernelPackages = pkgs.linuxPackages_cachyos;

    # Boot loader configuration (GRUB with BTRFS snapshot support)
    loader = {
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        # grub-btrfs will automatically add snapshot entries
      };
      efi.canTouchEfiVariables = true;
    };

    # Kernel parameters for AMD Ryzen AI Max+ 395
    # Note: Kernel 6.16.9+ auto-detects 96GB VRAM, no manual params needed!
    kernelParams = [
      "amd_pstate=active" # Enable AMD P-State driver
    ];

    # Early KMS for AMD GPU
    initrd.kernelModules = [ "amdgpu" ];
  };

  # NOTE: Single-drive configuration
  # All data (OS, AI models, context) stored on /dev/nvme0n1
  # Directory structure:
  #   / (root)
  #   ├─ /home/qalarc/local-llms/    # AI models directory
  #   └─ /home/qalarc/context/       # NixOS documentation context

  # Time and locale
  time.timeZone = "America/New_York"; # Adjust as needed
  i18n.defaultLocale = "en_US.UTF-8";

  # User account
  users.users.fivelidz = {
    isNormalUser = true;
    description = "QALARC User";
    extraGroups = [ "wheel" "networkmanager" "docker" "video" "render" ];
    # Set password with: passwd fivelidz
    # Or use hashedPassword for declarative password management
  };

  # Enable unfree packages (needed for NVIDIA tools, Chrome, etc.)
  nixpkgs.config.allowUnfree = true;

  # Nix settings
  nix = {
    settings = {
      # Enable flakes and nix-command
      experimental-features = [ "nix-command" "flakes" ];

      # Trust nixified.ai binary cache
      trusted-substituters = [ "https://ai.cachix.org" ];
      trusted-public-keys = [ "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc=" ];

      # Optimize builds
      auto-optimise-store = true;
      max-jobs = 16; # Match your CPU cores
    };

    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # All feature modules are imported in flake.nix
  # This file contains only host-specific configuration

  # Additional host-specific packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
  ];

  # Enable sound
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Hardware acceleration for AMD GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      rocmPackages.clr
      rocmPackages.clr.icd
    ];
  };

  # AMD GPU driver
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Environment variables for ROCm
  environment.variables = {
    ROC_ENABLE_PRE_VEGA = "1"; # Enable older GPU support if needed
    HSA_OVERRIDE_GFX_VERSION = "11.5.1"; # For gfx1151 (Radeon 8060S)
  };

  # Link ROCm to /opt/rocm for compatibility
  systemd.tmpfiles.rules =
    let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [
          rocblas
          hipblas
          clr
        ];
      };
    in
    [
      "L+ /opt/rocm - - - - ${rocmEnv}"
    ];

  # Create local-llms and context directories in user home
  systemd.tmpfiles.rules = [
    "d /home/fivelidz/local-llms 0755 fivelidz users -"
    "d /home/fivelidz/context 0755 fivelidz users -"
  ];
}
