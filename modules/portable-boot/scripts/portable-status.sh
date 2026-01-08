#!/usr/bin/env bash
# qalarc-portable-status: Show status of portable boot system

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           qalarc_OS Portable Boot Status                      ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check boot mode
if grep -q "copytoram" /proc/cmdline 2>/dev/null; then
    echo -e "Boot Mode:      ${GREEN}PORTABLE (RAM Boot)${NC}"
    PORTABLE_MODE=true
else
    echo -e "Boot Mode:      ${YELLOW}STANDARD (Normal Boot)${NC}"
    PORTABLE_MODE=false
fi

echo ""

if [ "$PORTABLE_MODE" = true ]; then
    # Memory usage
    echo -e "${CYAN}═══ Memory Usage ═══${NC}"
    free -h | head -2
    echo ""
    
    # Show RAM breakdown
    TOTAL_RAM=$(free -g | awk '/Mem:/ {print $2}')
    USED_RAM=$(free -g | awk '/Mem:/ {print $3}')
    AVAIL_RAM=$(free -g | awk '/Mem:/ {print $7}')
    
    echo "  Total RAM:     ${TOTAL_RAM}GB"
    echo "  Used:          ${USED_RAM}GB"
    echo "  Available:     ${AVAIL_RAM}GB"
    echo ""
    
    # Squashfs info
    echo -e "${CYAN}═══ System Image ═══${NC}"
    SQUASH_MOUNT=$(mount | grep squashfs | head -1 | awk '{print $3}')
    if [ -n "$SQUASH_MOUNT" ]; then
        SQUASH_SIZE=$(df -h "$SQUASH_MOUNT" 2>/dev/null | tail -1 | awk '{print $2}')
        echo "  Mounted at:    $SQUASH_MOUNT"
        echo "  Size:          $SQUASH_SIZE"
    else
        # Check tmpfs for copied squashfs
        TMPFS_SIZE=$(df -h /run/qalarc-ram 2>/dev/null | tail -1 | awk '{print $3}')
        if [ -n "$TMPFS_SIZE" ]; then
            echo "  System in RAM: $TMPFS_SIZE"
        fi
    fi
    echo ""
    
    # Overlay info
    echo -e "${CYAN}═══ Overlay Status ═══${NC}"
    OVERLAY_INFO=$(mount | grep "type overlay" | head -1)
    if [ -n "$OVERLAY_INFO" ]; then
        UPPER_SIZE=$(df -h /run/qalarc-upper 2>/dev/null | tail -1 | awk '{print $3 " / " $2}')
        echo "  Overlay active: Yes"
        echo "  Changes size:  ${UPPER_SIZE:-unknown}"
    else
        echo "  Overlay active: Unknown"
    fi
    echo ""
    
    # Persistence status
    echo -e "${CYAN}═══ Persistence ═══${NC}"
    PERSIST_DEV=$(blkid -L "QALARC_DATA" 2>/dev/null || true)
    
    if [ -n "$PERSIST_DEV" ]; then
        echo -e "  Partition:     ${GREEN}Found${NC} ($PERSIST_DEV)"
        
        if mountpoint -q /mnt/qalarc-persist 2>/dev/null; then
            PERSIST_USAGE=$(df -h /mnt/qalarc-persist | tail -1 | awk '{print $3 " / " $2 " (" $5 ")"}')
            echo -e "  Status:        ${GREEN}Mounted${NC}"
            echo "  Usage:         $PERSIST_USAGE"
        else
            echo -e "  Status:        ${YELLOW}Not mounted${NC}"
            echo "  Mount with:    sudo mount $PERSIST_DEV /mnt/qalarc-persist"
        fi
    else
        echo -e "  Partition:     ${YELLOW}Not found${NC}"
        echo "  Note:          USB may have been removed or created without persistence"
    fi
    echo ""
    
    # USB device info
    echo -e "${CYAN}═══ Boot Device ═══${NC}"
    BOOT_DEV=$(blkid -L "QALARC_BOOT" 2>/dev/null || true)
    if [ -n "$BOOT_DEV" ]; then
        echo -e "  Boot partition: ${GREEN}Connected${NC} ($BOOT_DEV)"
        echo -e "  ${YELLOW}USB can be safely removed - system is running from RAM${NC}"
    else
        echo -e "  Boot partition: ${GREEN}Disconnected${NC}"
        echo "  System is running entirely from RAM"
    fi
    echo ""
    
    # Quick tips
    echo -e "${CYAN}═══ Quick Commands ═══${NC}"
    echo "  Save changes:    sudo qalarc-sync-portable"
    echo "  Mount USB data:  sudo mount \$(blkid -L QALARC_DATA) /mnt/qalarc-persist"
    echo "  Check this:      qalarc-portable-status"
    
else
    # Not in portable mode
    echo "You are running a standard (non-portable) qalarc_OS installation."
    echo ""
    echo -e "${CYAN}═══ Create Portable USB ═══${NC}"
    echo ""
    echo "To create a portable USB drive:"
    echo "  1. GUI:  Open 'qalarc Portable Creator' from applications"
    echo "  2. CLI:  sudo qalarc-create-portable"
    echo ""
    echo "Requirements:"
    echo "  • USB drive or external SSD (16GB+ for base, 128GB+ with AI models)"
    echo "  • Target computer needs 8GB+ RAM (16GB+ recommended)"
    echo ""
    echo "For more info: /etc/qalarc-portable/PORTABLE_BOOT_GUIDE.md"
fi

echo ""
