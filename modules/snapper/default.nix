{ config, pkgs, lib, ... }:

{
  # Snapper configuration for BTRFS snapshots with GRUB integration

  # Install Snapper and related tools
  environment.systemPackages = with pkgs; [
    snapper
    snapper-gui  # GUI for browsing snapshots
    # grub-btrfs  # TODO: Not in nixpkgs 25.05 stable yet - add when available
  ];

  # Snapper configurations for different subvolumes
  services.snapper = {
    configs = {
      # Root filesystem snapshots
      root = {
        SUBVOLUME = "/";
        ALLOW_USERS = [ "qalarc" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;

        # Retention policy
        TIMELINE_LIMIT_HOURLY = "24";    # Keep 24 hourly snapshots (1 day)
        TIMELINE_LIMIT_DAILY = "7";      # Keep 7 daily snapshots (1 week)
        TIMELINE_LIMIT_WEEKLY = "4";     # Keep 4 weekly snapshots (1 month)
        TIMELINE_LIMIT_MONTHLY = "6";    # Keep 6 monthly snapshots (6 months)
        TIMELINE_LIMIT_YEARLY = "0";     # Don't keep yearly snapshots

        # Pre/post snapshots for package updates
        NUMBER_LIMIT = "10";             # Keep 10 pre/post snapshots
        NUMBER_MIN_AGE = "1800";         # Keep snapshots for at least 30 minutes

        # Cleanup algorithm
        NUMBER_CLEANUP = true;
        TIMELINE_MIN_AGE = "1800";       # Don't cleanup snapshots younger than 30 min
      };

      # Home directory snapshots
      home = {
        SUBVOLUME = "/home";
        ALLOW_USERS = [ "qalarc" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;

        # Less aggressive retention for home
        TIMELINE_LIMIT_HOURLY = "12";    # Keep 12 hourly snapshots (12 hours)
        TIMELINE_LIMIT_DAILY = "7";      # Keep 7 daily snapshots (1 week)
        TIMELINE_LIMIT_WEEKLY = "4";     # Keep 4 weekly snapshots (1 month)
        TIMELINE_LIMIT_MONTHLY = "3";    # Keep 3 monthly snapshots (3 months)

        NUMBER_LIMIT = "5";
        NUMBER_CLEANUP = true;
      };

      # Context library snapshots (code repos, Wikipedia, etc.)
      context = {
        SUBVOLUME = "/context";
        ALLOW_USERS = [ "qalarc" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;

        # Context doesn't change often, keep fewer snapshots
        TIMELINE_LIMIT_HOURLY = "0";     # No hourly snapshots
        TIMELINE_LIMIT_DAILY = "3";      # Keep 3 daily snapshots
        TIMELINE_LIMIT_WEEKLY = "2";     # Keep 2 weekly snapshots
        TIMELINE_LIMIT_MONTHLY = "2";    # Keep 2 monthly snapshots

        NUMBER_LIMIT = "5";
        NUMBER_CLEANUP = true;
      };
    };

    # Note: /local-llms and /nix are NOT snapshotted by default
    # - /nix: Managed by Nix, doesn't need snapshots
    # - /local-llms: Large model files, rarely change, snapshots waste space
    # You can manually snapshot these if needed
  };

  # Enable automatic timeline snapshots
  systemd.services.snapper-timeline.enable = true;
  systemd.timers.snapper-timeline.enable = true;

  # Enable automatic cleanup
  systemd.services.snapper-cleanup.enable = true;
  systemd.timers.snapper-cleanup.enable = true;

  # Pre/post snapshot hooks for NixOS rebuilds
  # This automatically creates snapshots before system updates
  system.activationScripts.snapper-pre-rebuild = lib.mkBefore ''
    if [ -e /run/current-system ]; then
      ${pkgs.snapper}/bin/snapper --config root create --description "pre-nixos-rebuild" --cleanup-algorithm number
    fi
  '';

  system.activationScripts.snapper-post-rebuild = lib.mkAfter ''
    ${pkgs.snapper}/bin/snapper --config root create --description "post-nixos-rebuild" --cleanup-algorithm number
  '';

  # grub-btrfs daemon for automatic GRUB menu updates
  # This watches /.snapshots and regenerates GRUB menu when snapshots change
  # TODO: Disabled until grub-btrfs is available in nixpkgs 25.05
  # systemd.services.grub-btrfsd = {
  #   description = "grub-btrfs daemon to update GRUB menu";
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = "${pkgs.grub-btrfs}/bin/grub-btrfsd --syslog /.snapshots";
  #     Restart = "on-failure";
  #     RestartSec = "10s";
  #   };
  #   wantedBy = [ "multi-user.target" ];
  # };

  # Ensure snapshot directory exists
  systemd.tmpfiles.rules = [
    "d /.snapshots 0750 root root -"
  ];

  # KDE keyboard shortcut for manual snapshots
  # This will be set up via KDE's custom shortcuts settings
  # The script creates a snapshot with a timestamp and shows a notification
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "qalarc-snapshot" ''
      #!/bin/sh
      # Manual snapshot creation script for CLI AI assistants and keyboard shortcuts

      TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
      DESCRIPTION="''${1:-manual-snapshot}"

      # Create snapshot
      ${pkgs.snapper}/bin/snapper --config root create \
        --description "$DESCRIPTION-$TIMESTAMP" \
        --cleanup-algorithm number

      # Show notification (if in GUI)
      if [ -n "$DISPLAY" ]; then
        ${pkgs.libnotify}/bin/notify-send "Snapshot Created" \
          "System snapshot created: $DESCRIPTION-$TIMESTAMP"
      fi

      # Export snapshot info as JSON for AI assistants
      ${pkgs.snapper}/bin/snapper --config root list --columns number,date,description --json \
        > /var/lib/qalarc/snapshots.json

      echo "Snapshot created: $DESCRIPTION-$TIMESTAMP"
    '')
  ];

  # CLI AI assistant interface:
  # - List snapshots: snapper list --json
  # - Create snapshot: qalarc-snapshot "description"
  # - Boot into snapshot: Select from GRUB menu (automatically generated)
  # - Restore from snapshot: snapper rollback <number>
  # - Snapshot stats: cat /var/lib/qalarc/snapshots.json

  # Keyboard shortcut setup (configured in KDE):
  # Super+Shift+S → qalarc-snapshot
  # This can be set via System Settings > Shortcuts > Custom Shortcuts
}
