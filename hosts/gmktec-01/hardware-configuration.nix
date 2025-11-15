# This file will be auto-generated during NixOS installation
# This is a TEMPLATE showing the expected BTRFS subvolume structure
#
# During installation, run:
#   nixos-generate-config --root /mnt
# Then replace this file with the generated hardware-configuration.nix

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # This is a template - actual values will be generated during installation
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # LUKS encryption (if enabled during installation)
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/nvme0n1p2"; # Adjust to your actual device
    # preLVM = true;
  };

  # Filesystem configuration with BTRFS subvolumes
  fileSystems."/" = {
    device = "/dev/mapper/cryptroot"; # Or /dev/nvme0n1p2 if not encrypted
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd:3" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd:3" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@nix" "noatime" ]; # No compression for Nix store
  };

  fileSystems."/local-llms" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@local-llms" "compress=zstd:1" "noatime" ];
  };

  fileSystems."/context" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@context" "compress=zstd:3" "noatime" ];
  };

  fileSystems."/.snapshots" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@snapshots" "noatime" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@var-log" "compress=zstd:3" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/nvme0n1p1"; # EFI partition
    fsType = "vfat";
  };

  # Swap configuration (optional - with 128GB RAM, swap may not be needed)
  # swapDevices = [ ];

  # CPU configuration
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
