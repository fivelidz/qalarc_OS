{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.qalarc.portableBoot;
  
  # Import scripts
  scripts = import ./scripts { inherit pkgs lib config; };

in
{
  imports = [
    ./options.nix
  ];

  config = mkIf cfg.enable {
    # Kernel modules for portable boot
    boot.initrd.availableKernelModules = [
      "overlay"
      "squashfs"
      "loop"
      "usb_storage"
      "uas"  # USB Attached SCSI (for USB SSDs)
    ];

    boot.initrd.supportedFilesystems = [ "squashfs" "overlay" "ext4" "vfat" ];

    # Custom initrd hook for copytoram
    boot.initrd.postDeviceCommands = mkIf cfg.copytoram.enable (mkAfter ''
      if grep -q "copytoram" /proc/cmdline; then
        echo "=== qalarc_OS Portable Boot: Loading to RAM ==="
        
        # Find boot partition by label
        BOOT_DEV=""
        for dev in /dev/sd* /dev/nvme*; do
          if [ -b "$dev" ]; then
            LABEL=$(blkid -s LABEL -o value "$dev" 2>/dev/null || true)
            if [ "$LABEL" = "QALARC_BOOT" ]; then
              BOOT_DEV="$dev"
              break
            fi
          fi
        done
        
        if [ -z "$BOOT_DEV" ]; then
          echo "Error: QALARC_BOOT partition not found"
          echo "Falling back to normal boot..."
        else
          mkdir -p /mnt-boot
          mount -t ext4 "$BOOT_DEV" /mnt-boot
          
          if [ -f "/mnt-boot/qalarc.squashfs" ]; then
            SQUASH_SIZE=$(stat -c%s /mnt-boot/qalarc.squashfs)
            SQUASH_MB=$((SQUASH_SIZE / 1024 / 1024))
            echo "Copying $SQUASH_MB MB to RAM..."
            
            # Create RAM disk
            mkdir -p /run/qalarc-ram
            mount -t tmpfs -o size=${cfg.copytoram.ramSize} tmpfs /run/qalarc-ram
            
            # Copy with progress (using dd with status)
            dd if=/mnt-boot/qalarc.squashfs of=/run/qalarc-ram/system.squashfs bs=4M status=progress 2>&1
            
            # Setup overlayfs
            mkdir -p /run/qalarc-lower /run/qalarc-upper /run/qalarc-work /sysroot
            mount -t squashfs -o loop,ro /run/qalarc-ram/system.squashfs /run/qalarc-lower
            
            mount -t tmpfs -o size=${cfg.copytoram.ramSize} tmpfs /run/qalarc-upper
            mkdir -p /run/qalarc-upper/upper /run/qalarc-upper/work
            
            mount -t overlay overlay \
              -o lowerdir=/run/qalarc-lower,upperdir=/run/qalarc-upper/upper,workdir=/run/qalarc-upper/work \
              /sysroot
            
            umount /mnt-boot
            echo "=== qalarc_OS loaded to RAM - USB can be removed ==="
          else
            echo "Warning: qalarc.squashfs not found"
            umount /mnt-boot
          fi
        fi
      fi
    '');

    # Add portable boot utilities
    environment.systemPackages = [
      scripts.qalarc-create-portable
      scripts.qalarc-sync-portable
      scripts.qalarc-portable-status
      scripts.qalarc-portable-gui
      pkgs.squashfsTools
      pkgs.parted
      pkgs.rsync
      pkgs.pv  # Progress viewer for dd
    ];

    # Desktop entry for GUI
    environment.etc."xdg/applications/qalarc-portable-creator.desktop".text = ''
      [Desktop Entry]
      Name=qalarc Portable Creator
      Comment=Create a portable qalarc_OS USB drive
      Exec=qalarc-portable-gui
      Icon=drive-removable-media
      Terminal=false
      Type=Application
      Categories=System;Utility;
      Keywords=usb;portable;boot;backup;
    '';

    # Documentation
    environment.etc."qalarc-portable/PORTABLE_BOOT_GUIDE.md".source = ./docs/PORTABLE_BOOT_GUIDE.md;

    # Auto-mount persistence if configured
    systemd.services.qalarc-mount-persistence = mkIf (cfg.persistence.enable && cfg.persistence.autoMount) {
      description = "Mount qalarc_OS persistence partition";
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      
      script = ''
        if grep -q "copytoram" /proc/cmdline; then
          PERSIST_DEV=$(${pkgs.util-linux}/bin/blkid -L "QALARC_DATA" 2>/dev/null || true)
          if [ -n "$PERSIST_DEV" ]; then
            mkdir -p ${cfg.persistence.mountPoint}
            ${pkgs.util-linux}/bin/mount "$PERSIST_DEV" ${cfg.persistence.mountPoint}
          fi
        fi
      '';
    };

    # Restore persistence on boot
    systemd.services.qalarc-restore-persistence = mkIf (cfg.persistence.enable && cfg.persistence.autoRestore) {
      description = "Restore data from persistence partition";
      wantedBy = [ "multi-user.target" ];
      after = [ "qalarc-mount-persistence.service" ];
      requires = [ "qalarc-mount-persistence.service" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      
      script = ''
        if grep -q "copytoram" /proc/cmdline && [ -d "${cfg.persistence.mountPoint}/home" ]; then
          echo "Restoring persistent home directories..."
          ${pkgs.rsync}/bin/rsync -a ${cfg.persistence.mountPoint}/home/ /home/
        fi
      '';
    };

    # Shell prompt indicator for portable mode
    programs.bash.interactiveShellInit = ''
      if grep -q "copytoram" /proc/cmdline 2>/dev/null; then
        export PS1="\[\033[1;33m\][PORTABLE]\[\033[0m\] $PS1"
      fi
    '';

    # Desktop notification
    systemd.user.services.qalarc-portable-notify = {
      description = "Notify user of portable boot mode";
      wantedBy = [ "graphical-session.target" ];
      
      serviceConfig.Type = "oneshot";
      
      script = ''
        if grep -q "copytoram" /proc/cmdline 2>/dev/null; then
          ${pkgs.libnotify}/bin/notify-send \
            -u normal \
            -i drive-removable-media \
            -t 10000 \
            "qalarc_OS Portable Mode" \
            "Running from RAM. Use 'qalarc-sync-portable' to save changes."
        fi
      '';
    };
  };
}
