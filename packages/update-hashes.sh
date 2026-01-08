#!/usr/bin/env bash
# Helper script to update package hashes for qalarc_OS custom packages

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "Qalarc OS Package Hash Updater"
echo "==============================="
echo ""

update_claude_code() {
    echo "Updating claude-code hashes..."
    echo ""
    
    VERSION="2.1.1"
    URL="https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${VERSION}.tgz"
    
    echo "Fetching source hash..."
    SRC_HASH=$(nix-prefetch-url "$URL" 2>&1 | tail -1)
    echo "Source hash: $SRC_HASH"
    
    echo ""
    echo "To get npmDepsHash:"
    echo "1. Update the source hash in packages/claude-code/default.nix"
    echo "2. Run: nix build .#claude-code"
    echo "3. Copy the 'got: sha256-...' hash from the error message"
    echo "4. Update npmDepsHash in the derivation"
    echo ""
}

update_opencode() {
    echo "Updating opencode hashes..."
    echo ""
    
    VERSION="0.0.55"
    
    echo "Fetching source hash..."
    if command -v nix-prefetch-github &> /dev/null; then
        nix-prefetch-github opencode-ai opencode --rev "v${VERSION}"
    else
        echo "nix-prefetch-github not found. Install with:"
        echo "  nix-shell -p nix-prefetch-github"
        echo ""
        echo "Alternatively, run:"
        echo "  nix build .#opencode"
        echo "And copy the hashes from error messages."
    fi
    
    echo ""
    echo "To get vendorHash:"
    echo "1. Update the source hash in packages/opencode/default.nix"
    echo "2. Run: nix build .#opencode"
    echo "3. Copy the 'got: sha256-...' hash from the error message"
    echo "4. Update vendorHash in the derivation"
    echo ""
}

case "${1:-}" in
    claude-code)
        update_claude_code
        ;;
    opencode)
        update_opencode
        ;;
    *)
        echo "Usage: $0 [claude-code|opencode]"
        echo ""
        echo "Updates package hashes for qalarc_OS custom packages."
        echo ""
        update_claude_code
        echo "---"
        echo ""
        update_opencode
        ;;
esac
