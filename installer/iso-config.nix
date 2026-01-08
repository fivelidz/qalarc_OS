{ config, pkgs, lib, modulesPath, ... }:

{
  # Custom NixOS installer ISO with qalarc_OS configuration pre-loaded
  # Build with: nix build .#nixosConfigurations.installer.config.system.build.isoImage

  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # ISO metadata
  isoImage.isoName = "qalarc-os-installer-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
  isoImage.volumeID = "QALARC_OS";

  # Boot configuration
  boot.kernelParams = [ "copytoram" ]; # Copy to RAM for faster operation

  # Include qalarc_OS repository on the ISO
  environment.etc."qalarc_OS".source = ../.;

  # Pre-install helpful packages on the live ISO
  environment.systemPackages = with pkgs; [
    # System utilities
    vim
    neovim
    git
    tmux
    wget
    curl
    htop
    btop

    # Partitioning tools
    parted
    gptfdisk
    btrfs-progs

    # Networking
    networkmanager
    tailscale

    # Hardware info
    lshw
    pciutils
    usbutils
    dmidecode

    # For AI/ROCm setup
    rocmPackages.rocm-smi
    rocmPackages.rocminfo

    # Quick install launcher
    (pkgs.writeShellScriptBin "qalarc-install" ''
      #!/bin/sh
      exec /etc/qalarc_OS/scripts/quick-install.sh "$@"
    '')

    # Installation helper script
    (pkgs.writeShellScriptBin "qalarc-install-help" ''
      #!/bin/sh
      cat << 'EOF'
      ╔════════════════════════════════════════════════════════════╗
      ║            qalarc_OS Installation Helper                   ║
      ╚════════════════════════════════════════════════════════════╝

      Installation Steps:

      1️⃣  VERIFY BIOS SETTINGS
         Reboot and check:
         - BIOS → Advanced → Graphics → Dedicated Memory = 96GB

      2️⃣  PARTITION DISK
         List disks: lsblk
         Partition: gdisk /dev/nvme0n1

         Recommended layout:
         - /dev/nvme0n1p1: 2GB (EFI - room for multiple kernels)
         - /dev/nvme0n1p2: Remaining (BTRFS + LUKS)

      3️⃣  ENCRYPT (Optional but recommended)
         cryptsetup luksFormat /dev/nvme0n1p2
         cryptsetup luksOpen /dev/nvme0n1p2 cryptroot

      4️⃣  FORMAT & MOUNT
         mkfs.fat -F32 /dev/nvme0n1p1
         mkfs.btrfs /dev/mapper/cryptroot  (or /dev/nvme0n1p2)

         Create subvolumes:
         mount /dev/mapper/cryptroot /mnt
         cd /mnt
         btrfs subvolume create @
         btrfs subvolume create @home
         btrfs subvolume create @nix
         btrfs subvolume create @local-llms
         btrfs subvolume create @context
         btrfs subvolume create @snapshots
         btrfs subvolume create @var-log

         Mount all:
         cd / && umount /mnt
         mount -o subvol=@,compress=zstd:3,noatime /dev/mapper/cryptroot /mnt
         mkdir -p /mnt/{boot,home,nix,local-llms,context,.snapshots,var/log}
         mount -o subvol=@home,compress=zstd:3,noatime /dev/mapper/cryptroot /mnt/home
         mount -o subvol=@nix,noatime /dev/mapper/cryptroot /mnt/nix
         mount -o subvol=@local-llms,compress=zstd:1,noatime /dev/mapper/cryptroot /mnt/local-llms
         mount -o subvol=@context,compress=zstd:3,noatime /dev/mapper/cryptroot /mnt/context
         mount -o subvol=@snapshots,noatime /dev/mapper/cryptroot /mnt/.snapshots
         mount -o subvol=@var-log,compress=zstd:3,noatime /dev/mapper/cryptroot /mnt/var/log
         mount /dev/nvme0n1p1 /mnt/boot

      5️⃣  GENERATE HARDWARE CONFIG
         nixos-generate-config --root /mnt
         cp /mnt/etc/nixos/hardware-configuration.nix /etc/qalarc_OS/hosts/gmktec-01/

      6️⃣  COPY CONFIG
         cp -r /etc/qalarc_OS /mnt/home/qalarc_OS

      7️⃣  INSTALL
         nixos-install --flake /etc/qalarc_OS#gmktec-01

         Set root password when prompted!

      8️⃣  REBOOT
         reboot
         Remove USB when system restarts

      For detailed guide: cat /etc/qalarc_OS/docs/INSTALLATION.md
      EOF
    '')
  ];

  # Enable NetworkManager for easier WiFi setup
  networking.networkmanager.enable = true;
  networking.wireless.enable = lib.mkForce false; # Disable wpa_supplicant

  # Enable SSH for remote installation (optional)
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Set a default password for live system
  # Use lib.mkForce to override the base installer's empty initialHashedPassword
  users.users.root = {
    initialHashedPassword = lib.mkForce null;
    initialPassword = "nixos";
  };
  users.users.nixos = {
    isNormalUser = true;
    initialHashedPassword = lib.mkForce null;
    initialPassword = "nixos";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Auto-login to TTY1 (installer runs automatically after login)
  services.getty.autologinUser = "nixos";

  # Passwordless sudo for installer user
  security.sudo.extraRules = [{
    users = [ "nixos" ];
    commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
  }];

  # Create welcome message
  environment.etc."issue".text = ''

    ╔════════════════════════════════════════════════════════════╗
    ║                                                            ║
    ║              Welcome to qalarc_OS Installer                ║
    ║              NixOS for AMD Ryzen AI Max+ 395               ║
    ║                                                            ║
    ╚════════════════════════════════════════════════════════════╝

    Login: nixos / Password: nixos (or root / nixos)

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    INSTALLATION OPTIONS:

    1. AUTOMATED INSTALL (Recommended):
       sudo qalarc-install

    2. MANUAL INSTALL:
       qalarc-install-help    # Show step-by-step guide
       cat /etc/qalarc_OS/docs/INSTALLATION.md

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    BEFORE YOU START:

    → Connect to internet first:
      - Ethernet: Should work automatically
      - WiFi: nmtui

    → Verify BIOS is configured (F2 at boot):
      - Advanced → Graphics → Dedicated Memory = 96GB

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  '';

  # Auto-run installer on login (with strong confirmation in the script)
  programs.bash.interactiveShellInit = ''
    # Show welcome and auto-launch installer
    cat /etc/issue
    echo ""
    echo "Starting qalarc_OS installer automatically..."
    echo ""
    sleep 2
    sudo /etc/qalarc_OS/scripts/quick-install.sh
  '';

  # Pre-configure git for the installation
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      user.name = "QALARC Installer";
      user.email = "installer@qalarc.local";
    };
  };

  # Increase console font size for readability
  console.font = "ter-v22n";
  console.packages = [ pkgs.terminus_font ];

  # System info
  system.stateVersion = "25.05";
}
