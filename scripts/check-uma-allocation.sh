#!/usr/bin/env bash
#
# check-uma-allocation.sh
# Verify that 96GB VRAM UMA allocation is working correctly
#

set -e

echo "═══════════════════════════════════════════════════════════"
echo "  QALARC UMA VRAM Allocation Check"
echo "  AMD Ryzen AI Max+ 395 - Unified Memory Architecture"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Check if ROCm tools are available
if ! command -v rocm-smi &> /dev/null; then
    echo "❌ rocm-smi not found. Installing rocm-smi..."
    echo "   Run: nix-shell -p rocmPackages.rocm-smi"
    exit 1
fi

echo "📊 System Memory:"
free -h | grep -E "Mem:|Swap:"
echo ""

echo "🎮 GPU Information (rocm-smi):"
rocm-smi --showproductname
echo ""

echo "💾 VRAM Allocation:"
rocm-smi --showmeminfo vram
echo ""

echo "🔍 Detailed GPU Memory:"
rocm-smi --showmeminfo vram --showmeminfo vis_vram --showmeminfo gtt --json | jq '.'
echo ""

# Check kernel version (6.16.9+ auto-detects 96GB)
KERNEL_VERSION=$(uname -r | cut -d'-' -f1)
echo "🐧 Kernel Version: $KERNEL_VERSION"
KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d'.' -f1)
KERNEL_MINOR=$(echo $KERNEL_VERSION | cut -d'.' -f2)
KERNEL_PATCH=$(echo $KERNEL_VERSION | cut -d'.' -f3)

if [ "$KERNEL_MAJOR" -ge 6 ] && [ "$KERNEL_MINOR" -ge 16 ] && [ "$KERNEL_PATCH" -ge 9 ]; then
    echo "✅ Kernel version supports automatic 96GB UMA detection"
else
    echo "⚠️  Kernel version may not auto-detect 96GB VRAM"
    echo "   Recommend upgrading to 6.16.9+"
fi
echo ""

# Check BIOS setting (indirect check via available memory)
VISIBLE_VRAM=$(rocm-smi --showmeminfo vram --json | jq -r '.[0].VRAM Total Memory (B)' 2>/dev/null | awk '{print int($1/1024/1024/1024)}')

if [ -n "$VISIBLE_VRAM" ]; then
    echo "📈 Visible VRAM: ${VISIBLE_VRAM}GB"

    if [ "$VISIBLE_VRAM" -ge 90 ]; then
        echo "✅ 96GB UMA allocation is working correctly!"
    elif [ "$VISIBLE_VRAM" -ge 30 ]; then
        echo "⚠️  VRAM allocation is lower than expected (${VISIBLE_VRAM}GB instead of 96GB)"
        echo "   Possible causes:"
        echo "   1. BIOS setting not configured (Set Dedicated Graphics Memory to 96GB)"
        echo "   2. Kernel too old (need 6.16.9+)"
        echo "   3. System has less than 128GB RAM"
    else
        echo "❌ VRAM allocation is significantly lower than expected"
        echo "   Please check BIOS settings and kernel version"
    fi
else
    echo "⚠️  Could not determine VRAM size"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  BIOS Configuration Instructions"
echo "═══════════════════════════════════════════════════════════"
echo "To enable 96GB VRAM allocation:"
echo "1. Reboot and enter BIOS (usually F2 or Del at boot)"
echo "2. Navigate to: Advanced → Graphics Configuration"
echo "3. Set 'Dedicated Graphics Memory' or 'UMA Frame Buffer Size' to 96GB"
echo "4. Save and exit BIOS"
echo "5. Boot into NixOS and run this script again"
echo ""
