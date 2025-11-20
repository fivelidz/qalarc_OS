{ config, pkgs, lib, ... }:

{
  # Minimal GMKTEC EVO-X2 configuration - just get it booting with KDE + SSH

  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "gmktec-minimal";

  # Enable networking
  networking.networkmanager.enable = true;

  # Timezone
  time.timeZone = "America/New_York";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # KDE Plasma
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Enable SSH
  services.openssh.enable = true;

  # User account
  users.users.qalarc = {
    isNormalUser = true;
    description = "QALARC User";
    extraGroups = [ "wheel" "networkmanager" "docker" "video" "render" ];
    initialPassword = "qalarc";  # Change after first login
  };

  # Basic packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    firefox
    nodejs_22
    ghostty
    tmux
    btop
    jq
  ];

  # Ollama AI service with GPU acceleration
  services.ollama = {
    enable = true;
    acceleration = "rocm";  # AMD GPU acceleration

    # CRITICAL: Pass GPU environment to systemd service
    environmentVariables = {
      # Override gfx1151 (RDNA4) to appear as gfx1100 (RDNA3)
      # gfx1100 = 11.0.0 (not 10.3.0 which is gfx1030)
      HSA_OVERRIDE_GFX_VERSION = "11.0.0";
      ROCR_VISIBLE_DEVICES = "0";  # Use first GPU
    };
  };

  # Environment variables for ROCm
  environment.variables = {
    HSA_OVERRIDE_GFX_VERSION = "11.0.0";
    ROCR_VISIBLE_DEVICES = "0";
    PYTORCH_ROCM_ARCH = "gfx1100";
  };

  # Docker for AI containers
  virtualisation.docker.enable = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable sudo
  security.sudo.wheelNeedsPassword = false;

  # System version
  system.stateVersion = "25.05";
}
