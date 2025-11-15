#!/usr/bin/env bash
#
# qalarc-ai-workspace.sh
# Launch TMUX workspace with local AI coding assistant (Qwen or similar)
# Similar interface to Claude Code, but using local models
#

set -e

# Configuration
SESSION_NAME="qalarc-ai"
AI_MODEL="${QALARC_AI_MODEL:-qwen2.5-coder:32b}"  # Default to Qwen 32B coder
OLLAMA_HOST="${OLLAMA_HOST:-http://localhost:11434}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Ollama is running
check_ollama() {
    if ! curl -s "$OLLAMA_HOST/api/tags" > /dev/null 2>&1; then
        log_error "Ollama is not running on $OLLAMA_HOST"
        log_info "Starting Ollama service..."
        sudo systemctl start ollama
        sleep 2
    fi
    log_success "Ollama is running"
}

# Check if AI model is available
check_model() {
    log_info "Checking for model: $AI_MODEL"
    if ! curl -s "$OLLAMA_HOST/api/tags" | jq -e ".models[] | select(.name | contains(\"$AI_MODEL\"))" > /dev/null 2>&1; then
        log_warn "Model $AI_MODEL not found"
        log_info "Pulling model... (this may take a while)"
        ollama pull "$AI_MODEL"
    fi
    log_success "Model $AI_MODEL is ready"
}

# Create system context file for AI
create_system_context() {
    cat > /tmp/qalarc-system-context.txt << 'EOF'
You are a helpful AI coding assistant running on a QALARC OS system.

System Information:
- OS: NixOS (qalarc_OS custom deployment)
- CPU: AMD Ryzen AI Max+ 395 (16 cores, Zen 5)
- GPU: AMD Radeon 8060S (96GB UMA VRAM)
- Memory: 128GB LPDDR5X-8000
- Filesystem: BTRFS with snapshots (Snapper)

Available Tools:
- System state: cat /var/lib/qalarc/system-state.json
- GPU stats: cat /var/lib/qalarc/gpu-stats.json
- Network status: qalarc-network-status
- Snapshots: snapper list, qalarc-snapshot
- File conversion: qalarc-convert
- NixOS rebuild: sudo nixos-rebuild switch --flake /home/qalarc/qalarc_OS#gmktec-01

Configuration Locations:
- NixOS config: /home/qalarc/qalarc_OS/
- System modules: /home/qalarc/qalarc_OS/modules/
- User home: /home/qalarc/
- AI models: /local-llms/
- Context library: /context/

When helping with code or system tasks:
1. Always provide complete, working code
2. Follow NixOS declarative paradigm
3. Use jq for JSON processing
4. Prefer nixpkgs over external downloads
5. Test commands before suggesting

Current working directory: $(pwd)
Current user: $(whoami)
EOF
}

# Launch TMUX workspace
launch_workspace() {
    log_info "Launching QALARC AI workspace..."

    # Create system context
    create_system_context

    # Check if session already exists
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_warn "Session '$SESSION_NAME' already exists. Attaching..."
        tmux attach-session -t "$SESSION_NAME"
        exit 0
    fi

    # Create new TMUX session with 3 panes
    tmux new-session -d -s "$SESSION_NAME" -n "qalarc-ai"

    # Pane 0 (main): AI chat interface
    tmux send-keys -t "$SESSION_NAME:0.0" "clear" C-m
    tmux send-keys -t "$SESSION_NAME:0.0" "echo '╔════════════════════════════════════════════════════════════════╗'" C-m
    tmux send-keys -t "$SESSION_NAME:0.0" "echo '║            QALARC AI CODING WORKSPACE                          ║'" C-m
    tmux send-keys -t "$SESSION_NAME:0.0" "echo '║            Model: $AI_MODEL'" C-m
    tmux send-keys -t "$SESSION_NAME:0.0" "echo '╚════════════════════════════════════════════════════════════════╝'" C-m
    tmux send-keys -t "$SESSION_NAME:0.0" "echo ''" C-m
    tmux send-keys -t "$SESSION_NAME:0.0" "echo 'Type your coding questions or commands. Examples:'" C-m
    tmux send-keys -t "$SESSION_NAME:0.0" "echo '  - Help me write a NixOS module for...'" C-m
    tmux send-keys -t "$SESSION_NAME:0.0" "echo '  - Debug this error: ...'" C-m
    tmux send-keys -t "$SESSION_NAME:0.0" "echo '  - Create a script that...'" C-m
    tmux send-keys -t "$SESSION_NAME:0.0" "echo '  - /system - Show system status'" C-m
    tmux send-keys -t "$SESSION_NAME:0.0" "echo '  - /gpu - Show GPU stats'" C-m
    tmux send-keys -t "$SESSION_NAME:0.0" "echo '  - /exit - Exit workspace'" C-m
    tmux send-keys -t "$SESSION_NAME:0.0" "echo ''" C-m

    # Start AI chat (using ollama run with system context)
    tmux send-keys -t "$SESSION_NAME:0.0" "ollama run $AI_MODEL --system \"$(cat /tmp/qalarc-system-context.txt)\"" C-m

    # Split horizontally (pane 1): System monitor
    tmux split-window -t "$SESSION_NAME:0" -v -p 30
    tmux send-keys -t "$SESSION_NAME:0.1" "btop" C-m

    # Split pane 1 vertically (pane 2): Command runner / file viewer
    tmux split-window -t "$SESSION_NAME:0.1" -h -p 50
    tmux send-keys -t "$SESSION_NAME:0.2" "clear" C-m
    tmux send-keys -t "$SESSION_NAME:0.2" "echo 'Command Runner / File Viewer'" C-m
    tmux send-keys -t "$SESSION_NAME:0.2" "echo 'Use this pane to:'" C-m
    tmux send-keys -t "$SESSION_NAME:0.2" "echo '  - Run commands suggested by AI'" C-m
    tmux send-keys -t "$SESSION_NAME:0.2" "echo '  - View files with: bat, cat, less'" C-m
    tmux send-keys -t "$SESSION_NAME:0.2" "echo '  - Test code snippets'" C-m
    tmux send-keys -t "$SESSION_NAME:0.2" "echo ''" C-m

    # Set pane 0 as main pane
    tmux select-pane -t "$SESSION_NAME:0.0"

    # Configure TMUX status bar
    tmux set-option -t "$SESSION_NAME" status-style "bg=colour235,fg=colour2"
    tmux set-option -t "$SESSION_NAME" status-left "#[fg=colour2,bold] QALARC AI #[fg=colour8]| "
    tmux set-option -t "$SESSION_NAME" status-right "#[fg=colour8]GPU: #[fg=colour2]$(cat /var/lib/qalarc/gpu-stats.json 2>/dev/null | jq -r '.[0].GPU_use' 2>/dev/null || echo 'N/A')% #[fg=colour8]| #[fg=colour2]%H:%M:%S "
    tmux set-option -t "$SESSION_NAME" status-interval 5

    log_success "Workspace launched successfully!"

    # Attach to session
    tmux attach-session -t "$SESSION_NAME"
}

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║          QALARC AI CODING WORKSPACE LAUNCHER                   ║"
    echo "║          Similar to Claude Code, but 100% local                ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""

    check_ollama
    check_model
    launch_workspace
}

# Handle command line arguments
case "${1:-}" in
    --model)
        AI_MODEL="$2"
        shift 2
        ;;
    --help|-h)
        cat << EOF
Usage: qalarc-ai-workspace.sh [OPTIONS]

Launch a TMUX-based AI coding workspace with local models.

Options:
    --model MODEL    Specify AI model to use (default: qwen2.5-coder:32b)
    --help, -h       Show this help message

Environment Variables:
    QALARC_AI_MODEL  Default AI model to use
    OLLAMA_HOST      Ollama API endpoint (default: http://localhost:11434)

Examples:
    qalarc-ai-workspace.sh
    qalarc-ai-workspace.sh --model deepseek-coder:33b
    QALARC_AI_MODEL=llama3.1:70b qalarc-ai-workspace.sh

Keyboard Shortcuts (in TMUX):
    Ctrl+B then arrow keys  - Navigate between panes
    Ctrl+B then [           - Scroll mode (press q to exit)
    Ctrl+B then d           - Detach (workspace keeps running)
    Ctrl+B then x           - Close current pane

To reattach to existing workspace:
    tmux attach-session -t qalarc-ai
EOF
        exit 0
        ;;
esac

main
