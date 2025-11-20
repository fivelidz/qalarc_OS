{ config, pkgs, lib, ... }:

{
  # Portable qalarc_OS for External NVMe Drive
  # Self-contained, bootable on multiple systems with LUKS encryption

  imports = [
    ./hardware-configuration.nix
  ];

  # ═══════════════════════════════════════════════════════════════════
  # BOOTLOADER - Universal GRUB for EFI systems
  # ═══════════════════════════════════════════════════════════════════

  boot.loader = {
    efi = {
      canTouchEfiVariables = false;  # Don't modify host EFI - portable
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;  # Install to /EFI/BOOT/BOOTX64.EFI
      device = "nodev";
      useOSProber = false;  # Don't probe other OSes
      configurationLimit = 10;
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # KERNEL - Generic hardware support
  # ═══════════════════════════════════════════════════════════════════

  boot.initrd = {
    availableKernelModules = [
      # Storage
      "nvme" "ahci" "sd_mod" "sr_mod" "usb_storage" "uas"
      # USB/Thunderbolt
      "xhci_pci" "thunderbolt" "usbhid"
      # Encryption
      "dm_crypt" "cryptd" "aes" "sha256"
      # Filesystem
      "btrfs"
    ];

    kernelModules = [ "dm-snapshot" "amdgpu" ];

    # LUKS encryption for root
    luks.devices."portable-root" = {
      # Will be replaced with actual UUID during installation
      device = "/dev/disk/by-uuid/LUKS-UUID-PLACEHOLDER";
      preLVM = true;
      allowDiscards = true;  # TRIM for SSD performance
      bypassWorkqueues = true;  # Better performance
    };
  };

  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];  # Support both

  # ═══════════════════════════════════════════════════════════════════
  # NETWORKING - Auto-detect
  # ═══════════════════════════════════════════════════════════════════

  networking = {
    hostName = "qalarc-portable";
    networkmanager.enable = true;
    # Generate unique hostId from hardware
    hostId = "a1b2c3d4";  # Replace with: head -c 8 /etc/machine-id
  };

  # ═══════════════════════════════════════════════════════════════════
  # DESKTOP ENVIRONMENT
  # ═══════════════════════════════════════════════════════════════════

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Generic video drivers - works on AMD, Intel, NVIDIA
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" "modesetting" ];

  # ═══════════════════════════════════════════════════════════════════
  # SNAPPER - Btrfs snapshots for hot-unplug safety
  # ═══════════════════════════════════════════════════════════════════

  services.snapper = {
    snapshotInterval = "hourly";
    cleanupInterval = "1d";

    configs = {
      root = {
        SUBVOLUME = "/";
        ALLOW_GROUPS = [ "wheel" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_MIN_AGE = 1800;
        TIMELINE_LIMIT_HOURLY = 5;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 2;
        TIMELINE_LIMIT_MONTHLY = 1;
      };

      home = {
        SUBVOLUME = "/home";
        ALLOW_GROUPS = [ "wheel" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = 10;
        TIMELINE_LIMIT_DAILY = 10;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 6;
      };
    };
  };

  # Create snapper snapshot directories
  systemd.tmpfiles.rules = [
    "d /.snapshots 0750 root wheel -"
    "d /home/.snapshots 0750 root wheel -"
  ];

  # ═══════════════════════════════════════════════════════════════════
  # OLLAMA AI SERVICE
  # ═══════════════════════════════════════════════════════════════════

  services.ollama = {
    enable = true;
    acceleration = "rocm";

    environmentVariables = {
      # Support multiple GPU architectures
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";  # RDNA3 compatibility
      ROCR_VISIBLE_DEVICES = "0";
    };
  };

  # Environment for ROCm
  environment.variables = {
    HSA_OVERRIDE_GFX_VERSION = "10.3.0";
    ROCR_VISIBLE_DEVICES = "0";
    PYTORCH_ROCM_ARCH = "gfx1100";
  };

  # ═══════════════════════════════════════════════════════════════════
  # PACKAGES
  # ═══════════════════════════════════════════════════════════════════

  environment.systemPackages = with pkgs; [
    # Core
    vim git wget curl htop btop

    # Terminal
    ghostty tmux

    # Development
    nodejs_22 python3 jq ripgrep fd

    # System tools
    cryptsetup btrfs-progs snapper
    pciutils usbutils lshw

    # Networking
    networkmanager

    # Browser
    firefox

    # File management
    rsync unzip
  ];

  # ═══════════════════════════════════════════════════════════════════
  # USERS
  # ═══════════════════════════════════════════════════════════════════

  users.users.qalarc = {
    isNormalUser = true;
    description = "QALARC User";
    extraGroups = [ "wheel" "networkmanager" "docker" "video" "render" ];
    initialPassword = "qalarc";
  };

  # ═══════════════════════════════════════════════════════════════════
  # SERVICES
  # ═══════════════════════════════════════════════════════════════════

  services.openssh.enable = true;
  virtualisation.docker.enable = true;

  # Pipewire audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # SYSTEM
  # ═══════════════════════════════════════════════════════════════════

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05";
}
