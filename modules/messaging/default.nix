{ config, pkgs, lib, ... }:

{
  # Qalarc Messaging Module
  # Signal CLI, WhatsApp (nchat), and messaging bridges
  
  environment.systemPackages = with pkgs; [
    # ========================================================================
    # SIGNAL
    # ========================================================================
    signal-cli          # Command-line Signal client
    signal-desktop      # GUI Signal client
    
    # ========================================================================
    # WHATSAPP
    # ========================================================================
    nchat               # Terminal-based WhatsApp + Telegram client
    
    # ========================================================================
    # MATRIX BRIDGES (for advanced users)
    # ========================================================================
    # These allow bridging Signal/WhatsApp to Matrix
    # Commented out by default - enable if needed
    # mautrix-whatsapp  # WhatsApp bridge
    # mautrix-signal    # Signal bridge
    
    # ========================================================================
    # HELPER SCRIPTS
    # ========================================================================
    
    # qalarc-signal - Quick Signal CLI wrapper
    (writeShellScriptBin "qalarc-signal" ''
      #!/usr/bin/env bash
      
      # Qalarc Signal CLI Helper
      
      CONFIG_DIR="$HOME/.config/signal-cli"
      
      show_help() {
        echo ""
        echo -e "\033[36m  Qalarc Signal CLI\033[0m"
        echo ""
        echo "  Usage: qalarc-signal <command>"
        echo ""
        echo "  Commands:"
        echo "    register <phone>   Register a new Signal account"
        echo "    verify <code>      Verify registration with SMS code"
        echo "    send <to> <msg>    Send a message"
        echo "    receive            Receive pending messages"
        echo "    daemon             Start in daemon mode (for bots)"
        echo "    link               Link as secondary device (scan QR)"
        echo "    status             Show account status"
        echo ""
        echo "  Examples:"
        echo "    qalarc-signal register +1234567890"
        echo "    qalarc-signal verify 123456"
        echo "    qalarc-signal send +1234567890 'Hello!'"
        echo ""
      }
      
      case "''${1:-help}" in
        register)
          if [ -z "$2" ]; then
            echo "Error: Phone number required"
            echo "Usage: qalarc-signal register +1234567890"
            exit 1
          fi
          signal-cli -a "$2" register
          ;;
        verify)
          if [ -z "$2" ]; then
            echo "Error: Verification code required"
            exit 1
          fi
          PHONE=$(ls "$CONFIG_DIR/data/" 2>/dev/null | head -1 | sed 's/+/%2B/')
          if [ -z "$PHONE" ]; then
            echo "Error: No account found. Run 'register' first."
            exit 1
          fi
          signal-cli -a "+$PHONE" verify "$2"
          ;;
        send)
          if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Error: Recipient and message required"
            echo "Usage: qalarc-signal send +1234567890 'message'"
            exit 1
          fi
          PHONE=$(ls "$CONFIG_DIR/data/" 2>/dev/null | head -1)
          signal-cli -a "$PHONE" send -m "$3" "$2"
          ;;
        receive)
          PHONE=$(ls "$CONFIG_DIR/data/" 2>/dev/null | head -1)
          signal-cli -a "$PHONE" receive
          ;;
        daemon)
          PHONE=$(ls "$CONFIG_DIR/data/" 2>/dev/null | head -1)
          echo "Starting Signal daemon for $PHONE..."
          signal-cli -a "$PHONE" daemon
          ;;
        link)
          echo "Generating QR code for device linking..."
          echo "Scan this with your Signal mobile app:"
          signal-cli link -n "Qalarc-OS"
          ;;
        status)
          echo ""
          echo -e "\033[36mSignal CLI Status\033[0m"
          echo ""
          if [ -d "$CONFIG_DIR/data" ]; then
            echo "Registered accounts:"
            ls "$CONFIG_DIR/data/" 2>/dev/null | while read acc; do
              echo "  - $acc"
            done
          else
            echo "  No accounts registered"
          fi
          echo ""
          ;;
        help|--help|-h|*)
          show_help
          ;;
      esac
    '')
    
    # qalarc-whatsapp - Quick WhatsApp (nchat) wrapper
    (writeShellScriptBin "qalarc-whatsapp" ''
      #!/usr/bin/env bash
      
      # Qalarc WhatsApp Helper (via nchat)
      
      show_help() {
        echo ""
        echo -e "\033[36m  Qalarc WhatsApp (nchat)\033[0m"
        echo ""
        echo "  nchat is a terminal-based WhatsApp client."
        echo ""
        echo "  Usage: qalarc-whatsapp [command]"
        echo ""
        echo "  Commands:"
        echo "    start      Launch nchat (default)"
        echo "    setup      First-time setup instructions"
        echo "    help       Show this help"
        echo ""
      }
      
      show_setup() {
        echo ""
        echo -e "\033[36m  WhatsApp Setup via nchat\033[0m"
        echo ""
        echo "  1. Run: qalarc-whatsapp start"
        echo "  2. Press Ctrl+G to show setup menu"
        echo "  3. Select 'WhatsApp' and scan QR code with phone"
        echo "  4. Your chats will sync automatically"
        echo ""
        echo "  Keyboard shortcuts in nchat:"
        echo "    Ctrl+G    Show menu"
        echo "    Ctrl+X    Exit"
        echo "    Tab       Switch chats"
        echo "    Ctrl+U    Upload file"
        echo ""
      }
      
      case "''${1:-start}" in
        start)
          nchat
          ;;
        setup)
          show_setup
          ;;
        help|--help|-h)
          show_help
          ;;
        *)
          nchat
          ;;
      esac
    '')
  ];
  
  # Create config directories for new users
  systemd.tmpfiles.rules = [
    "d /home/qalarc/.config/signal-cli 0700 qalarc users -"
    "d /home/qalarc/.config/nchat 0700 qalarc users -"
  ];
}
