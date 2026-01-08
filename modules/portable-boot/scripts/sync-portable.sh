#!/usr/bin/env bash
# qalarc-sync-portable: Sync RAM changes back to USB persistence partition

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PERSIST_MOUNT="/mnt/qalarc-persist"

die() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

check_portable_mode() {
    if ! grep -q "copytoram" /proc/cmdline; then
        die "Not running in portable boot mode. This command only works on portable qalarc_OS."
    fi
}

find_persistence() {
    PERSIST_DEV=$(blkid -L "QALARC_DATA" 2>/dev/null || true)
    
    if [ -z "$PERSIST_DEV" ]; then
        die "Persistence partition not found. Was this USB created with persistence enabled?"
    fi
    
    echo "Found persistence partition: $PERSIST_DEV"
}

mount_persistence() {
    if mountpoint -q "$PERSIST_MOUNT"; then
        echo "Persistence already mounted at $PERSIST_MOUNT"
        return
    fi
    
    mkdir -p "$PERSIST_MOUNT"
    mount "$PERSIST_DEV" "$PERSIST_MOUNT"
    success "Mounted persistence partition"
}

show_space() {
    echo ""
    echo -e "${BLUE}Persistence partition usage:${NC}"
    df -h "$PERSIST_MOUNT" | tail -1 | awk '{print "  Used: " $3 " / " $2 " (" $5 " full)"}'
    echo ""
}

sync_home() {
    echo "Syncing /home to persistence..."
    rsync -av --delete --progress /home/ "$PERSIST_MOUNT/home/"
    success "Home directories synced"
}

sync_etc() {
    echo "Syncing /etc to persistence..."
    rsync -av --progress /etc/ "$PERSIST_MOUNT/etc/"
    success "System configuration synced"
}

sync_var() {
    echo "Syncing /var to persistence (excluding temp files)..."
    rsync -av --progress \
        --exclude='tmp/*' \
        --exclude='cache/*' \
        --exclude='log/*' \
        /var/ "$PERSIST_MOUNT/var/"
    success "Variable data synced"
}

sync_custom() {
    read -p "Enter path to sync: " custom_path
    
    if [ ! -e "$custom_path" ]; then
        echo -e "${RED}Path does not exist: $custom_path${NC}"
        return
    fi
    
    echo "Syncing $custom_path..."
    
    # Create parent directory in persistence
    parent_dir=$(dirname "$custom_path")
    mkdir -p "$PERSIST_MOUNT$parent_dir"
    
    rsync -av --progress "$custom_path" "$PERSIST_MOUNT$parent_dir/"
    success "Custom path synced"
}

interactive_menu() {
    echo ""
    echo -e "${BLUE}What would you like to sync?${NC}"
    echo ""
    echo "  1) Home directories only (/home)"
    echo "  2) System configuration only (/etc)"
    echo "  3) Everything (home + etc + var)"
    echo "  4) Custom path"
    echo "  5) Show current persistence contents"
    echo "  6) Exit"
    echo ""
    read -p "Choice [3]: " choice
    choice=${choice:-3}
    
    case $choice in
        1)
            sync_home
            ;;
        2)
            sync_etc
            ;;
        3)
            sync_home
            sync_etc
            sync_var
            ;;
        4)
            sync_custom
            ;;
        5)
            echo ""
            echo -e "${BLUE}Contents of persistence partition:${NC}"
            ls -la "$PERSIST_MOUNT"
            echo ""
            du -sh "$PERSIST_MOUNT"/* 2>/dev/null || echo "(empty)"
            echo ""
            interactive_menu
            return
            ;;
        6)
            exit 0
            ;;
        *)
            echo "Invalid choice"
            interactive_menu
            return
            ;;
    esac
}

# Parse arguments
case "${1:-}" in
    --home)
        check_portable_mode
        find_persistence
        mount_persistence
        sync_home
        show_space
        ;;
    --etc)
        check_portable_mode
        find_persistence
        mount_persistence
        sync_etc
        show_space
        ;;
    --all)
        check_portable_mode
        find_persistence
        mount_persistence
        sync_home
        sync_etc
        sync_var
        show_space
        ;;
    --help|-h)
        echo "Usage: qalarc-sync-portable [OPTION]"
        echo ""
        echo "Sync RAM changes back to USB persistence partition."
        echo ""
        echo "Options:"
        echo "  --home    Sync home directories only"
        echo "  --etc     Sync system configuration only"
        echo "  --all     Sync everything (home, etc, var)"
        echo "  --help    Show this help"
        echo ""
        echo "With no options, runs interactive menu."
        exit 0
        ;;
    "")
        # Interactive mode
        echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          qalarc_OS Portable Sync Utility                      ║${NC}"
        echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
        
        check_portable_mode
        find_persistence
        mount_persistence
        show_space
        interactive_menu
        show_space
        
        success "Sync complete! Changes will persist across reboots."
        ;;
    *)
        die "Unknown option: $1. Use --help for usage."
        ;;
esac
