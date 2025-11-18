#!/bin/bash
# qalarc_OS Application Test Suite
# Run this script to test all GUI applications

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "================================================"
echo "  qalarc_OS Application Test Suite"
echo "================================================"
echo ""

test_app() {
    local name="$1"
    local cmd="$2"
    local wait_time="${3:-3}"

    echo -n "Testing $name... "

    # Launch app in background
    $cmd &>/dev/null &
    local pid=$!

    # Wait for it to start
    sleep $wait_time

    # Check if still running
    if kill -0 $pid 2>/dev/null; then
        echo -e "${GREEN}✓ WORKS${NC}"
        kill $pid 2>/dev/null || true
        return 0
    else
        echo -e "${RED}✗ CRASHED${NC}"
        return 1
    fi
}

echo "=== TERMINALS ==="
test_app "Ghostty" "ghostty" 2
test_app "Konsole" "konsole" 2

echo ""
echo "=== CODE EDITORS ==="
test_app "VSCode" "code --new-window" 3
test_app "Kate" "kate" 2

echo ""
echo "=== BROWSERS ==="
test_app "Brave" "brave" 3
test_app "Chrome" "google-chrome-stable" 3

echo ""
echo "=== FILE MANAGERS ==="
test_app "Dolphin" "dolphin" 2

echo ""
echo "=== MEDIA ==="
test_app "VLC" "vlc" 2
test_app "OBS" "obs" 3

echo ""
echo "=== GRAPHICS ==="
test_app "GIMP" "gimp" 3
test_app "Inkscape" "inkscape" 3
test_app "Krita" "krita" 3

echo ""
echo "=== OFFICE ==="
test_app "LibreOffice Writer" "libreoffice --writer" 3

echo ""
echo "=== UTILITIES ==="
test_app "Okular (PDF)" "okular" 2
test_app "Spectacle (Screenshot)" "spectacle" 2
test_app "Ark (Archive)" "ark" 2

echo ""
echo "=== DEVELOPMENT ==="
test_app "DBeaver" "dbeaver" 4
test_app "Postman" "postman" 4

echo ""
echo "=== SYSTEM ==="
test_app "System Monitor (btop)" "konsole -e btop" 2

echo ""
echo "================================================"
echo "  Test Complete!"
echo "================================================"
echo ""
echo "Note: Apps that crashed may have specific issues."
echo "Check logs with: journalctl -b | grep <app-name>"
