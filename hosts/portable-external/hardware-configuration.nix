{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ═══════════════════════════════════════════════════════════════════
  # HARDWARE CONFIGURATION FOR PORTABLE EXTERNAL NVME
  #
  # This config uses LUKS + BTRFS with snapper-compatible subvolumes
  # Replace UUIDs with actual values during installation
  # ═══════════════════════════════════════════════════════════════════

  # EFI Boot Partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EFI-UUID-PLACEHOLDER";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  # Root filesystem - BTRFS on LUKS
  # Subvolume layout for snapper compatibility
  fileSystems."/" = {
    device = "/dev/mapper/portable-root";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd:3"
      "noatime"
      "ssd"
      "discard=async"
      "space_cache=v2"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/portable-root";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd:3"
      "noatime"
      "ssd"
      "discard=async"
      "space_cache=v2"
    ];
  };

  fileSystems."/.snapshots" = {
    device = "/dev/mapper/portable-root";
    fsType = "btrfs";
    options = [
      "subvol=@snapshots"
      "compress=zstd:3"
      "noatime"
      "ssd"
      "discard=async"
      "space_cache=v2"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/portable-root";
    fsType = "btrfs";
    options = [
      "subvol=@nix"
      "compress=zstd:3"
      "noatime"
      "ssd"
      "discard=async"
      "space_cache=v2"
    ];
    neededForBoot = true;
  };

  fileSystems."/var/log" = {
    device = "/dev/mapper/portable-root";
    fsType = "btrfs";
    options = [
      "subvol=@log"
      "compress=zstd:3"
      "noatime"
      "ssd"
      "discard=async"
      "space_cache=v2"
    ];
  };

  # Swap file on btrfs (optional - can use zram instead)
  swapDevices = [ ];

  # Use zram for swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # ═══════════════════════════════════════════════════════════════════
  # CPU/GPU - Support multiple architectures
  # ═══════════════════════════════════════════════════════════════════

  # AMD by default, but works on Intel too
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Enable all firmware
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # Platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
