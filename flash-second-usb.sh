#!/bin/bash
# Flash installer ISO to second STORE N GO USB (/dev/sdc)

ISO_FILE="/home/fivelidz/projects/qalarc_OS/result/iso/nixos-minimal-25.05.20251124.1c8ba8d-x86_64-linux.iso"
USB_DEVICE="/dev/sdc"
PASSWORD="Turing"

echo "Flashing ISO to second STORE N GO USB..."
echo "ISO file: $ISO_FILE"
echo "Target USB: $USB_DEVICE"
echo "ISO size: $(du -h "$ISO_FILE" | cut -f1)"
echo ""
echo "⚠️  This will DESTROY all data on $USB_DEVICE!"
echo ""

# Unmount USB if mounted
echo "$PASSWORD" | sudo -S umount ${USB_DEVICE}* 2>/dev/null || true
echo ""

# Flash ISO
echo "$PASSWORD" | sudo -S dd \
    if="$ISO_FILE" \
    of="$USB_DEVICE" \
    bs=4M \
    status=progress \
    conv=fsync

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Flash complete!"
    echo ""
    echo "Syncing..."
    sync
    echo ""
    echo "✓ Second STORE N GO USB is ready!"
else
    echo ""
    echo "✗ Flash failed!"
    exit 1
fi
