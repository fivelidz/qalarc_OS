{ config, pkgs, lib, ... }:

{
  # Torrent client system for context library distribution
  # Primary use case: Syncing large offline datasets (Wikipedia, code repos, etc.)

  environment.systemPackages = with pkgs; [
    # GUI torrent clients
    qbittorrent      # Feature-rich, popular
    transmission-gtk # Lightweight alternative

    # CLI torrent clients
    transmission     # Daemon + CLI
    aria2            # Multi-protocol downloader (HTTP, FTP, BitTorrent)

    # Torrent utilities
    mktorrent        # Create .torrent files
  ];

  # qBittorrent systemd service (runs as user service)
  # Accessible via web UI at http://localhost:8080
  systemd.user.services.qbittorrent = {
    description = "qBittorrent torrent client (headless)";
    after = [ "network.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.qbittorrent}/bin/qbittorrent-nox";
      Restart = "on-failure";
      RestartSec = "10s";
    };

    # Enable with: systemctl --user enable qbittorrent
    wantedBy = [ "default.target" ];
  };

  # Transmission daemon (alternative to qBittorrent)
  services.transmission = {
    enable = false;  # Disabled by default, enable if preferred over qBittorrent

    settings = {
      # Download directory
      download-dir = "/context/torrents/completed";
      incomplete-dir = "/context/torrents/incomplete";

      # Web UI settings
      rpc-bind-address = "0.0.0.0";
      rpc-port = 9091;
      rpc-whitelist = "127.0.0.1,192.168.*.*";
      rpc-username = "qalarc";
      # Set password with: transmission-remote --auth qalarc:password --authenv

      # Performance settings
      peer-limit-global = 200;
      peer-limit-per-torrent = 50;
      upload-slots-per-torrent = 10;

      # Speed limits (optional)
      speed-limit-down-enabled = false;
      speed-limit-up-enabled = false;

      # Seeding ratio (1.0 = seed until 1:1 ratio)
      ratio-limit-enabled = true;
      ratio-limit = 2.0;  # Seed until 2:1 ratio
    };
  };

  # Create torrent directories
  systemd.tmpfiles.rules = [
    "d /context/torrents 0755 qalarc users -"
    "d /context/torrents/completed 0755 qalarc users -"
    "d /context/torrents/incomplete 0755 qalarc users -"
    "d /context/torrents/watch 0755 qalarc users -"  # Auto-add .torrent files here
  ];

  # Firewall rules for torrent clients
  networking.firewall = {
    allowedTCPPorts = [
      # qBittorrent
      8080   # Web UI
      6881   # Incoming connections

      # Transmission (if enabled)
      # 9091   # Web UI
      # 51413  # Incoming connections
    ];

    allowedUDPPorts = [
      6881   # qBittorrent DHT
      # 51413  # Transmission DHT
    ];
  };

  # Helper script for creating torrents from context library
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "qalarc-create-torrent" ''
      #!/bin/sh
      # Create a .torrent file from a directory or file
      # Usage: qalarc-create-torrent <path> [tracker-url]

      if [ $# -lt 1 ]; then
        echo "Usage: qalarc-create-torrent <path> [tracker-url]"
        echo ""
        echo "Examples:"
        echo "  qalarc-create-torrent /context/github-repos/nixpkgs"
        echo "  qalarc-create-torrent /context/wikipedia/en-wiki.zim https://tracker.example.com/announce"
        exit 1
      fi

      SOURCE_PATH="$1"
      TRACKER_URL="''${2:-https://tracker.opentrackr.org:443/announce}"  # Public tracker default
      OUTPUT_DIR="/context/torrents"

      if [ ! -e "$SOURCE_PATH" ]; then
        echo "Error: Path does not exist: $SOURCE_PATH"
        exit 1
      fi

      BASENAME=$(basename "$SOURCE_PATH")
      TORRENT_FILE="$OUTPUT_DIR/$BASENAME.torrent"

      echo "Creating torrent file..."
      echo "  Source: $SOURCE_PATH"
      echo "  Tracker: $TRACKER_URL"
      echo "  Output: $TORRENT_FILE"

      ${pkgs.mktorrent}/bin/mktorrent \
        -a "$TRACKER_URL" \
        -o "$TORRENT_FILE" \
        "$SOURCE_PATH"

      echo ""
      echo "✅ Torrent created: $TORRENT_FILE"
      echo ""
      echo "Next steps:"
      echo "  1. Start seeding: Copy .torrent to qBittorrent"
      echo "  2. Share .torrent file or magnet link with others"
      echo "  3. qBittorrent web UI: http://localhost:8080"
    '')

    (writeShellScriptBin "qalarc-torrent-status" ''
      #!/bin/sh
      # Show status of torrent clients and active downloads

      echo "╔════════════════════════════════════════════════════════════╗"
      echo "║          QALARC Torrent System Status                     ║"
      echo "╚════════════════════════════════════════════════════════════╝"
      echo ""

      # qBittorrent status
      if systemctl --user is-active qbittorrent >/dev/null 2>&1; then
        echo "✅ qBittorrent: RUNNING"
        echo "   Web UI: http://localhost:8080"
        echo "   Default login: admin / adminadmin (change this!)"
      else
        echo "❌ qBittorrent: STOPPED"
        echo "   Start with: systemctl --user start qbittorrent"
      fi

      echo ""

      # Transmission status (if enabled)
      if systemctl is-active transmission >/dev/null 2>&1; then
        echo "✅ Transmission: RUNNING"
        echo "   Web UI: http://localhost:9091"
      else
        echo "⚪ Transmission: DISABLED"
      fi

      echo ""

      # Disk usage
      echo "📊 Torrent Storage:"
      if [ -d /context/torrents ]; then
        du -sh /context/torrents/* 2>/dev/null || echo "   No torrents yet"
      else
        echo "   Directory not created yet"
      fi

      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "Context Library Torrents:"
      if [ -d /context/torrents ]; then
        find /context/torrents -name "*.torrent" -exec basename {} \; 2>/dev/null | head -10
      fi
    '')
  ];

  # Usage documentation for AI assistants
  # CLI AI assistant interface:
  # - Start qBittorrent: systemctl --user start qbittorrent
  # - Web UI: http://localhost:8080 (user: admin, default pass: adminadmin)
  # - Create torrent: qalarc-create-torrent /path/to/data
  # - Check status: qalarc-torrent-status
  # - Auto-add torrents: Drop .torrent files in /context/torrents/watch/

  # Use cases:
  # 1. Sync offline Wikipedia: Download Wikipedia ZIM via torrent
  # 2. Distribute code repos: Create torrents of GitHub mirrors
  # 3. Share AI models: Create torrents of large model files
  # 4. Context library updates: Torrent new versions of datasets
}
