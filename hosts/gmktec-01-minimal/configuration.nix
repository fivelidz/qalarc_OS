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
    extraGroups = [ "wheel" "networkmanager" ];
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
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable sudo
  security.sudo.wheelNeedsPassword = false;

  # System version
  system.stateVersion = "25.05";
}
