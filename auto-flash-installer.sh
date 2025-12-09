#!/bin/bash
# Auto-flash installer ISO to STORE N GO USB when build completes

BUILD_DIR="/home/fivelidz/projects/qalarc_OS"
USB_DEVICE="/dev/sdc"
PASSWORD="Turing"

echo "Waiting for ISO build to complete..."
echo "Build directory: $BUILD_DIR"
echo "Target USB: $USB_DEVICE (STORE N GO)"
echo ""

# Wait for result symlink to appear
while [ ! -L "$BUILD_DIR/result" ]; do
    echo -n "."
    sleep 10
done

echo ""
echo "✓ Build complete! ISO found."

# Find the ISO file
ISO_FILE=$(ls -1 $BUILD_DIR/result/iso/*.iso 2>/dev/null | head -1)

if [ -z "$ISO_FILE" ]; then
    echo "✗ ERROR: No ISO file found in result/iso/"
    exit 1
fi

echo "ISO file: $ISO_FILE"
ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)
echo "ISO size: $ISO_SIZE"
echo ""

# Unmount USB if mounted
echo "Unmounting $USB_DEVICE..."
echo "$PASSWORD" | sudo -S umount ${USB_DEVICE}* 2>/dev/null || true
echo ""

# Flash ISO
echo "Flashing ISO to $USB_DEVICE..."
echo "⚠️  This will DESTROY all data on STORE N GO USB!"
echo ""

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
    echo "✓ All done! STORE N GO USB is ready."
    echo ""
    echo "Next steps:"
    echo "  1. Safely eject USB: sudo eject $USB_DEVICE"
    echo "  2. Boot GMKTEC from this USB"
    echo "  3. Follow installer instructions"
else
    echo ""
    echo "✗ Flash failed!"
    exit 1
fi
