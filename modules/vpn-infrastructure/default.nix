{ config, pkgs, lib, ... }:

{
  # VPN Infrastructure Module
  # Comprehensive VPN system with Tailscale, WireGuard, and OpenVPN

  environment.systemPackages = with pkgs; [
    # VPN clients
    tailscale        # Zero-config mesh VPN (primary)
    wireguard-tools  # WireGuard CLI tools
    openvpn          # OpenVPN client/server

    # Network utilities
    netcat
    nmap
    iperf3
    traceroute
    mtr
    speedtest-cli
  ];

  # Tailscale (Primary VPN - Zero Config Mesh Network)
  services.tailscale = {
    enable = true;
    # After boot, run: sudo tailscale up
    # Get status: tailscale status
    # Get IP: tailscale ip
  };

  # WireGuard - Manual VPN Configuration
  # Uncomment and configure for site-to-site VPN or custom mesh
  # networking.wireguard.interfaces = {
  #   wg0 = {
  #     # Local WireGuard IP
  #     ips = [ "10.100.0.2/24" ];
  #
  #     # Port to listen on (UDP)
  #     listenPort = 51820;
  #
  #     # Private key location (generate with: wg genkey)
  #     privateKeyFile = "/root/wireguard/private.key";
  #
  #     # Peers (other WireGuard nodes)
  #     peers = [
  #       {
  #         # Public key of peer (generate with: wg pubkey < private.key)
  #         publicKey = "PEER_PUBLIC_KEY_HERE";
  #
  #         # Allowed IPs (what traffic routes through this peer)
  #         allowedIPs = [ "10.100.0.0/24" ];
  #
  #         # Endpoint (peer's public IP:port)
  #         endpoint = "peer.example.com:51820";
  #
  #         # Keep connection alive (for NAT traversal)
  #         persistentKeepalive = 25;
  #       }
  #     ];
  #   };
  # };

  # OpenVPN client configurations
  # Place .ovpn files in /etc/openvpn/ and manage with systemd
  # services.openvpn.servers = {
  #   client = {
  #     config = '' config /etc/openvpn/client.ovpn '';
  #     autoStart = false;  # Start manually with: systemctl start openvpn-client
  #   };
  # };

  # Firewall configuration for VPNs
  networking.firewall = {
    # Enable NAT for VPN routing (if this machine is a VPN gateway)
    # nat.enable = true;
    # nat.externalInterface = "eno1";  # Your internet-facing interface
    # nat.internalInterfaces = [ "wg0" "tailscale0" ];

    # Tailscale
    checkReversePath = "loose";  # Required for Tailscale
    trustedInterfaces = [ "tailscale0" ];

    # WireGuard
    allowedUDPPorts = [
      51820  # WireGuard default port
    ];

    # OpenVPN
    # allowedTCPPorts = [ 1194 ];  # OpenVPN TCP
    # allowedUDPPorts = [ 1194 ];  # OpenVPN UDP
  };

  # Helper scripts for VPN management
  environment.systemPackages = with pkgs; [
    # WireGuard key generation and management
    (writeShellScriptBin "qalarc-wg-keygen" ''
      #!/bin/sh
      # Generate WireGuard key pair
      # Usage: qalarc-wg-keygen [output-dir]

      OUTPUT_DIR="''${1:-/root/wireguard}"
      mkdir -p "$OUTPUT_DIR"
      chmod 700 "$OUTPUT_DIR"

      echo "Generating WireGuard key pair..."

      # Generate private key
      wg genkey > "$OUTPUT_DIR/private.key"
      chmod 600 "$OUTPUT_DIR/private.key"

      # Generate public key from private key
      cat "$OUTPUT_DIR/private.key" | wg pubkey > "$OUTPUT_DIR/public.key"

      echo ""
      echo "✅ Keys generated in: $OUTPUT_DIR"
      echo ""
      echo "Private key: $OUTPUT_DIR/private.key"
      cat "$OUTPUT_DIR/private.key"
      echo ""
      echo "Public key: $OUTPUT_DIR/public.key"
      cat "$OUTPUT_DIR/public.key"
      echo ""
      echo "⚠️  Keep private.key SECRET! Share public.key with peers."
    '')

    # WireGuard configuration generator
    (writeShellScriptBin "qalarc-wg-config" ''
      #!/bin/sh
      # Generate WireGuard configuration template
      # Usage: qalarc-wg-config <interface-name>

      INTERFACE="''${1:-wg0}"

      cat << EOF
# WireGuard Configuration Template for $INTERFACE
# Add this to /etc/nixos/configuration.nix or qalarc_OS modules

networking.wireguard.interfaces = {
  $INTERFACE = {
    # Local WireGuard IP
    ips = [ "10.100.0.2/24" ];  # Change this!

    # Port to listen on (UDP)
    listenPort = 51820;

    # Private key location
    privateKeyFile = "/root/wireguard/private.key";

    # Peers
    peers = [
      {
        # Peer's public key
        publicKey = "PASTE_PEER_PUBLIC_KEY_HERE";

        # What IPs can be routed through this peer
        allowedIPs = [ "10.100.0.0/24" ];

        # Peer's endpoint (IP:port)
        endpoint = "peer.example.com:51820";

        # Keep connection alive (NAT traversal)
        persistentKeepalive = 25;
      }
    ];
  };
};
EOF
    '')

    # VPN status checker
    (writeShellScriptBin "qalarc-vpn-status" ''
      #!/bin/sh
      # Check status of all VPN connections

      echo "╔════════════════════════════════════════════════════════════╗"
      echo "║              QALARC VPN Infrastructure Status              ║"
      echo "╚════════════════════════════════════════════════════════════╝"
      echo ""

      # Tailscale status
      echo "━━━ Tailscale (Mesh VPN) ━━━"
      if systemctl is-active tailscaled >/dev/null 2>&1; then
        if tailscale status >/dev/null 2>&1; then
          echo "✅ Status: CONNECTED"
          echo "📡 Tailscale IP: $(tailscale ip -4 2>/dev/null || echo 'N/A')"
          echo "🌐 Hostname: $(tailscale status --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.Self.HostName' 2>/dev/null || echo 'N/A')"
          echo ""
          echo "Connected peers:"
          tailscale status 2>/dev/null | grep -v "^#" | head -5
        else
          echo "⚠️  Status: NOT CONNECTED"
          echo "   Run: sudo tailscale up"
        fi
      else
        echo "❌ Status: NOT RUNNING"
        echo "   Run: sudo systemctl start tailscaled"
      fi

      echo ""
      echo "━━━ WireGuard ━━━"
      if ${pkgs.wireguard-tools}/bin/wg show >/dev/null 2>&1; then
        WG_INTERFACES=$(${pkgs.wireguard-tools}/bin/wg show interfaces)
        if [ -n "$WG_INTERFACES" ]; then
          echo "✅ Active interfaces: $WG_INTERFACES"
          ${pkgs.wireguard-tools}/bin/wg show
        else
          echo "⚪ No active interfaces"
        fi
      else
        echo "⚪ Not configured"
      fi

      echo ""
      echo "━━━ OpenVPN ━━━"
      if systemctl list-units --type=service --state=running | grep -q openvpn; then
        echo "✅ Active connections:"
        systemctl list-units --type=service --state=running | grep openvpn
      else
        echo "⚪ No active connections"
      fi

      echo ""
      echo "━━━ Network Interfaces ━━━"
      ${pkgs.iproute2}/bin/ip -br addr show | grep -E "tailscale|wg|tun|tap"

      echo ""
      echo "━━━ Routing Table ━━━"
      ${pkgs.iproute2}/bin/ip route | grep -E "tailscale|wg|tun|tap" || echo "No VPN routes"

      echo ""
    '')

    # VPN speed test
    (writeShellScriptBin "qalarc-vpn-speedtest" ''
      #!/bin/sh
      # Test VPN connection speed
      # Usage: qalarc-vpn-speedtest [target-ip]

      TARGET="''${1:-8.8.8.8}"

      echo "Testing connection to $TARGET..."
      echo ""

      # Ping test
      echo "━━━ Latency Test ━━━"
      ping -c 5 "$TARGET"

      echo ""
      echo "━━━ MTR Test (route + latency) ━━━"
      ${pkgs.mtr}/bin/mtr -r -c 10 "$TARGET"

      if command -v iperf3 >/dev/null 2>&1; then
        echo ""
        echo "For bandwidth test, set up iperf3 server on peer:"
        echo "  Server: iperf3 -s"
        echo "  Client: iperf3 -c [server-ip]"
      fi
    '')
  ];

  # Split tunneling configuration (route only specific traffic through VPN)
  # This is useful for routing only torrent traffic through VPN, for example
  # networking.resolvconf.extraConfig = ''
  #   # Use VPN DNS only for specific domains
  #   name_servers_search="vpn.example.com"
  # '';

  # Kill switch (block all traffic if VPN disconnects)
  # Uncomment to enable strict VPN-only networking
  # networking.firewall = {
  #   extraCommands = ''
  #     # Block all traffic except to VPN server
  #     iptables -A OUTPUT -d VPN_SERVER_IP -j ACCEPT
  #     iptables -A OUTPUT -o wg0 -j ACCEPT
  #     iptables -A OUTPUT -o tailscale0 -j ACCEPT
  #     iptables -A OUTPUT -j DROP
  #   '';
  # };

  # Usage notes for AI assistants:
  # - Tailscale setup: sudo tailscale up
  # - Check VPN status: qalarc-vpn-status
  # - Generate WireGuard keys: qalarc-wg-keygen
  # - Test VPN speed: qalarc-vpn-speedtest [peer-ip]
  # - WireGuard config: Edit networking.wireguard.interfaces in configuration.nix

  # Use cases:
  # 1. Remote LLM access: Access Ollama from phone via Tailscale
  # 2. Site-to-site VPN: Connect multiple GMKTEC systems with WireGuard
  # 3. Privacy: Route torrent traffic through VPN
  # 4. Development: Test network configurations
}
