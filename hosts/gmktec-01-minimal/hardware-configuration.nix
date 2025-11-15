# This is a TEMPLATE hardware configuration for single-drive setup
# During installation, run: nixos-generate-config --root /mnt
# Then copy /mnt/etc/nixos/hardware-configuration.nix to this file

# Example structure (will be auto-generated):
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Boot configuration
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Filesystems - EXAMPLE (replace with actual UUIDs from nixos-generate-config)
  # NOTE: This file MUST be replaced with actual hardware-configuration.nix during install!

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-ACTUAL-UUID";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-ACTUAL-UUID";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # Swap configuration (optional, adjust size as needed)
  # swapDevices = [ ];

  # CPU configuration
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Network
  networking.useDHCP = lib.mkDefault true;
}
