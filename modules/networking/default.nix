{ config, pkgs, lib, ... }:

{
  # Networking configuration: VPN, SSH, Remote Access, Streaming

  # NetworkManager for easy network configuration
  networking.networkmanager.enable = true;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    # Allow ports for various services
    allowedTCPPorts = [
      22     # SSH
      11434  # Ollama API
      47984  # Sunshine (HTTPS)
      47989  # Sunshine (HTTP)
      48010  # Sunshine (Web UI)
    ];
    allowedUDPPorts = [
      47998  # Sunshine (Video)
      47999  # Sunshine (Audio)
      48000  # Sunshine (Control)
      48002  # Sunshine (RTSP)
    ];

    # Tailscale uses UDP 41641, but it configures firewall automatically
    checkReversePath = "loose";  # Required for Tailscale
  };

  # SSH server for remote access
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;  # Enable password auth for remote management
      PermitRootLogin = "no";
      X11Forwarding = true;  # Allow graphical app forwarding
    };
    # SSH keys should be configured per-user in home-manager or users.users.<name>.openssh.authorizedKeys
  };

  # Tailscale - zero-config mesh VPN (easiest remote access)
  services.tailscale = {
    enable = true;
    # After enabling, run: sudo tailscale up
    # Access from phone/laptop anywhere via Tailscale IP
  };

  # Sunshine - desktop/game streaming server (for Moonlight clients)
  # Note: Sunshine may not be in nixpkgs yet, so we'll add it as an overlay or build manually

  # WireGuard support (if needed instead of Tailscale)
  # Uncomment to enable manual WireGuard configuration
  # networking.wireguard.interfaces = {
  #   wg0 = {
  #     ips = [ "10.100.0.2/24" ];
  #     privateKeyFile = "/root/wireguard-keys/private";
  #     peers = [{
  #       publicKey = "<peer-public-key>";
  #       allowedIPs = [ "10.100.0.0/24" ];
  #       endpoint = "<server-ip>:51820";
  #       persistentKeepalive = 25;
  #     }];
  #   };
  # };

  # OpenVPN support (for compatibility)
  services.openvpn.servers = {
    # Example OpenVPN client configuration
    # client = {
    #   config = '' config /path/to/client.ovpn '';
    #   autoStart = false;
    # };
  };

  # Avahi for local network discovery (mDNS/DNS-SD)
  services.avahi = {
    enable = lib.mkDefault true;
    nssmdns4 = lib.mkDefault true;
    publish = {
      enable = lib.mkDefault true;
      addresses = lib.mkDefault true;
      domain = lib.mkDefault true;
      hinfo = lib.mkDefault true;
      userServices = lib.mkDefault true;
      workstation = lib.mkDefault true;
    };
  };

  # Samba for file sharing with Windows/Mac (optional)
  # Uncomment to enable:
  # services.samba = {
  #   enable = true;
  #   securityType = "user";
  #   shares = {
  #     public = {
  #       path = "/home/qalarc/Public";
  #       browseable = "yes";
  #       "read only" = "no";
  #       "guest ok" = "yes";
  #     };
  #   };
  # };

  # NFS for network file sharing (optional, for NAS integration)
  # services.nfs.server.enable = true;

  # CLI AI assistant network status script
  environment.systemPackages = with pkgs; [
    # Sunshine is not yet in nixpkgs stable, so we'll note it for manual install or overlay
    # For now, users can install via flatpak or compile from source
    # sunshine  # TODO: Add when available

    # Alternative: Use Steam Link or other streaming solutions
    # For now, include dependencies
    libva
    libva-utils
    vulkan-tools

    (writeShellScriptBin "qalarc-network-status" ''
      #!/bin/sh
      # Network status for AI assistant queries

      echo "{"
      echo "  \"interfaces\": $(${pkgs.iproute2}/bin/ip -j addr show),"
      echo "  \"tailscale\": $(${pkgs.tailscale}/bin/tailscale status --json 2>/dev/null || echo '{"error":"not running"}'),"
      echo "  \"ssh\": {"
      echo "    \"enabled\": $(systemctl is-active sshd | grep -q active && echo "true" || echo "false"),"
      echo "    \"port\": 22"
      echo "  },"
      echo "  \"ollama\": {"
      echo "    \"enabled\": $(systemctl is-active ollama | grep -q active && echo "true" || echo "false"),"
      echo "    \"port\": 11434"
      echo "  }"
      echo "}"
    '')

    # Network testing tools
    curl
    wget
    nmap
    iperf3
    mtr
    traceroute
    tcpdump
    wireshark  # GUI network analyzer
  ];

  # Create qalarc state directory
  systemd.tmpfiles.rules = [
    "d /var/lib/qalarc 0755 root root -"
  ];

  # Network status export service - disabled by default to avoid boot errors
  # Enable after full configuration is applied
  # systemd.services.network-status-export = {
  #   description = "Export network status for AI assistant consumption";
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "/run/current-system/sw/bin/qalarc-network-status";
  #     StandardOutput = "file:/var/lib/qalarc/network-status.json";
  #   };
  # };
  #
  # systemd.timers.network-status-export = {
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnBootSec = "1min";
  #     OnUnitActiveSec = "5min";
  #   };
  # };

  # CLI AI assistant interface:
  # - Network status: qalarc-network-status
  # - Tailscale status: tailscale status --json
  # - SSH connections: ss -tnp | grep ':22'
  # - Ollama API test: curl http://localhost:11434/api/tags
  # - Full status: cat /var/lib/qalarc/network-status.json
}
