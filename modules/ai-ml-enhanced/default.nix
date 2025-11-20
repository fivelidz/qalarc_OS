{ config, pkgs, lib, nixified-ai, ... }:

{
  # Enhanced AI/ML module - CLI-first with text-generation-webui option
  # Philosophy: Terminal workflows are primary, web UI is supplementary

  environment.systemPackages = with pkgs; [
    # ═══════════════════════════════════════════════════════════
    # CLI-FIRST INFERENCE ENGINES (Primary)
    # ═══════════════════════════════════════════════════════════

    # llama.cpp - Core C++ library with CLI
    llama-cpp  # Optimized via performance overlay

    # Ollama - Simple CLI + REST API
    # (Configured via services below)

    # ═══════════════════════════════════════════════════════════
    # NEOVIM AI PLUGINS (Terminal coding assistants)
    # ═══════════════════════════════════════════════════════════

    # Note: Neovim plugins installed via home-manager or manually
    # Users can choose one or multiple:
    #   - llama.vim (simple, direct llama.cpp integration)
    #   - codecompanion.nvim (multi-backend, feature-rich)
    #   - avante.nvim (Cursor-like, agentic)
    #   - llm.nvim (flexible backends)
    #   - Minuet (as-you-type completion)

    # Required dependencies for Neovim AI plugins
    nodejs_22       # For some plugins
    python312       # For Python-based plugins
    curl            # For API calls
    jq              # For JSON processing

    # ═══════════════════════════════════════════════════════════
    # PYTHON ML/AI ENVIRONMENT
    # ═══════════════════════════════════════════════════════════

    python312
    python312Packages.pip
    python312Packages.virtualenv

    # PyTorch with ROCm (optimized via overlay)
    python312Packages.torch
    python312Packages.torchvision
    python312Packages.torchaudio

    # HuggingFace ecosystem
    python312Packages.transformers
    python312Packages.accelerate
    python312Packages.datasets
    python312Packages.tokenizers

    # Utilities
    python312Packages.numpy
    python312Packages.pandas
    python312Packages.scipy
    python312Packages.scikit-learn
    python312Packages.jupyter
    python312Packages.ipython
    python312Packages.requests

    # ═══════════════════════════════════════════════════════════
    # ROCm TOOLS & MONITORING
    # ═══════════════════════════════════════════════════════════

    rocmPackages.rocm-smi      # GPU monitoring (like nvidia-smi)
    rocmPackages.rocminfo      # ROCm system information
    rocmPackages.rocm-runtime  # Runtime libraries
    clinfo                     # OpenCL information

    # ═══════════════════════════════════════════════════════════
    # MODEL MANAGEMENT & DOWNLOAD
    # ═══════════════════════════════════════════════════════════

    huggingface-cli  # Download models from HuggingFace

    # ═══════════════════════════════════════════════════════════
    # WEB UI OPTION (text-generation-webui)
    # ═══════════════════════════════════════════════════════════

    # text-generation-webui installation via Python venv
    # See helper script: qalarc-setup-textgen-webui
    # Not directly in nixpkgs, so we install via pip in isolated env

    # Dependencies for text-generation-webui
    git-lfs  # For downloading large model files
  ];

  # ═══════════════════════════════════════════════════════════
  # OLLAMA SERVICE (CLI + REST API)
  # ═══════════════════════════════════════════════════════════

  services.ollama = {
    enable = true;
    acceleration = "rocm";  # AMD GPU acceleration
    # Models stored in /var/lib/ollama or custom location
    # Override with: home = "/local-llms/ollama";

    # CRITICAL: Pass GPU environment to systemd service
    environmentVariables = {
      # Override gfx1151 (RDNA4) to appear as gfx1100 (RDNA3)
      # Format: MAJOR.MINOR.STEPPING → 10.3.0 for gfx1100
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";
      ROCR_VISIBLE_DEVICES = "0";           # Use first GPU
    };
  };

  # ═══════════════════════════════════════════════════════════
  # ENVIRONMENT VARIABLES
  # ═══════════════════════════════════════════════════════════

  environment.variables = {
    # ROCm device selection
    ROCR_VISIBLE_DEVICES = "0";  # Use first GPU (Radeon 8060S)

    # HIP/ROCm configuration for gfx1151 → override to gfx1100 (RDNA3)
    HSA_OVERRIDE_GFX_VERSION = "10.3.0";
    PYTORCH_ROCM_ARCH = "gfx1100";  # For PyTorch ROCm compatibility

    # Ollama configuration
    OLLAMA_HOST = "127.0.0.1:11434";  # Local only by default
    OLLAMA_MODELS = "/local-llms/ollama/models";

    # HuggingFace cache
    HF_HOME = "/local-llms/huggingface";
    TRANSFORMERS_CACHE = "/local-llms/huggingface/transformers";

    # Python environment
    PYTHONPATH = "$PYTHONPATH:${pkgs.python312Packages.torch}/${pkgs.python312.sitePackages}";

    # llama.cpp settings
    LLAMA_CPP_VERBOSE = "0";  # Quiet mode for CLI use
  };

  # ═══════════════════════════════════════════════════════════
  # HELPER SCRIPTS (CLI-FOCUSED)
  # ═══════════════════════════════════════════════════════════

  environment.systemPackages = with pkgs; [

    # ──────────────────────────────────────────────────────────
    # 1. OLLAMA CLI HELPERS
    # ──────────────────────────────────────────────────────────

    (writeShellScriptBin "qalarc-ollama-status" ''
      #!/bin/sh
      # Check Ollama status and models

      echo "╔════════════════════════════════════════════════════════════╗"
      echo "║              QALARC Ollama Status                          ║"
      echo "╚════════════════════════════════════════════════════════════╝"
      echo ""

      # Service status
      if systemctl is-active ollama >/dev/null 2>&1; then
        echo "✅ Ollama: RUNNING"
        echo "   API: http://localhost:11434"
      else
        echo "❌ Ollama: STOPPED"
        echo "   Start with: sudo systemctl start ollama"
        exit 1
      fi

      echo ""
      echo "━━━ Installed Models ━━━"
      ${pkgs.ollama}/bin/ollama list

      echo ""
      echo "━━━ Model Storage ━━━"
      du -sh /local-llms/ollama 2>/dev/null || echo "No models yet"

      echo ""
      echo "━━━ GPU Status ━━━"
      ${pkgs.rocmPackages.rocm-smi}/bin/rocm-smi --showuse --showmeminfo vram 2>/dev/null | head -10

      echo ""
      echo "Quick commands:"
      echo "  ollama pull qwen2.5-coder:32b   # Download coding model"
      echo "  ollama run qwen2.5-coder:32b    # Interactive chat"
      echo "  ollama list                      # List models"
      echo "  ollama rm <model>                # Remove model"
    '')

    (writeShellScriptBin "qalarc-ollama-chat" ''
      #!/bin/sh
      # Quick CLI chat with Ollama
      # Usage: qalarc-ollama-chat [model]

      MODEL="''${1:-qwen2.5-coder:32b}"

      if ! systemctl is-active ollama >/dev/null 2>&1; then
        echo "❌ Ollama not running. Start with: sudo systemctl start ollama"
        exit 1
      fi

      # Check if model exists
      if ! ${pkgs.ollama}/bin/ollama list | grep -q "$MODEL"; then
        echo "⚠️  Model '$MODEL' not found. Pulling..."
        ${pkgs.ollama}/bin/ollama pull "$MODEL"
      fi

      echo "🤖 Starting chat with $MODEL"
      echo "   Type /bye to exit, /? for help"
      echo ""

      ${pkgs.ollama}/bin/ollama run "$MODEL"
    '')

    # ──────────────────────────────────────────────────────────
    # 2. LLAMA.CPP CLI WRAPPER
    # ──────────────────────────────────────────────────────────

    (writeShellScriptBin "qalarc-llama" ''
      #!/bin/sh
      # llama.cpp CLI wrapper for direct model inference
      # Usage: qalarc-llama <model.gguf> [prompt]

      if [ $# -lt 1 ]; then
        echo "Usage: qalarc-llama <model.gguf> [prompt]"
        echo ""
        echo "Examples:"
        echo "  qalarc-llama /local-llms/qwen2.5-coder-32b.Q4_K_M.gguf"
        echo "  qalarc-llama model.gguf 'Write a Python function to...'"
        echo ""
        echo "Models location: /local-llms/"
        exit 1
      fi

      MODEL="$1"
      shift

      if [ ! -f "$MODEL" ]; then
        echo "❌ Model not found: $MODEL"
        exit 1
      fi

      PROMPT="''${@:-}"

      # If prompt provided, run once; otherwise interactive
      if [ -n "$PROMPT" ]; then
        ${pkgs.llama-cpp}/bin/llama-cli \
          --model "$MODEL" \
          --prompt "$PROMPT" \
          --n-gpu-layers 999 \
          --threads $(nproc) \
          --ctx-size 4096
      else
        ${pkgs.llama-cpp}/bin/llama-cli \
          --model "$MODEL" \
          --interactive \
          --n-gpu-layers 999 \
          --threads $(nproc) \
          --ctx-size 8192
      fi
    '')

    # ──────────────────────────────────────────────────────────
    # 3. TEXT-GENERATION-WEBUI SETUP & MANAGEMENT
    # ──────────────────────────────────────────────────────────

    (writeShellScriptBin "qalarc-setup-textgen-webui" ''
      #!/bin/sh
      # Install text-generation-webui in isolated Python environment
      # Installation location: /local-llms/text-generation-webui

      INSTALL_DIR="/local-llms/text-generation-webui"

      echo "╔════════════════════════════════════════════════════════════╗"
      echo "║       Text Generation WebUI Installer                      ║"
      echo "╚════════════════════════════════════════════════════════════╝"
      echo ""

      if [ -d "$INSTALL_DIR" ]; then
        echo "⚠️  text-generation-webui already installed at $INSTALL_DIR"
        echo ""
        read -p "Reinstall? (y/N): " reinstall
        if [ "$reinstall" != "y" ] && [ "$reinstall" != "Y" ]; then
          echo "Aborted."
          exit 0
        fi
        rm -rf "$INSTALL_DIR"
      fi

      mkdir -p "$(dirname "$INSTALL_DIR")"

      echo "📥 Cloning text-generation-webui..."
      git clone https://github.com/oobabooga/text-generation-webui "$INSTALL_DIR"
      cd "$INSTALL_DIR"

      echo ""
      echo "🐍 Creating Python virtual environment..."
      ${pkgs.python312}/bin/python -m venv venv

      echo ""
      echo "📦 Installing dependencies (this will take 10-15 minutes)..."
      source venv/bin/activate
      pip install --upgrade pip

      # Install PyTorch with ROCm
      pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.2

      # Install text-generation-webui requirements
      pip install -r requirements.txt

      # Install additional backends
      pip install llama-cpp-python  # llama.cpp backend
      # pip install exllamav2  # ExLlamaV2 backend (if needed)

      echo ""
      echo "✅ Installation complete!"
      echo ""
      echo "Start text-generation-webui with:"
      echo "  qalarc-start-textgen-webui"
      echo ""
      echo "Or manually:"
      echo "  cd $INSTALL_DIR"
      echo "  source venv/bin/activate"
      echo "  python server.py --listen --api"
    '')

    (writeShellScriptBin "qalarc-start-textgen-webui" ''
      #!/bin/sh
      # Start text-generation-webui server
      # Access at: http://localhost:7860

      INSTALL_DIR="/local-llms/text-generation-webui"

      if [ ! -d "$INSTALL_DIR" ]; then
        echo "❌ text-generation-webui not installed"
        echo "   Run: qalarc-setup-textgen-webui"
        exit 1
      fi

      cd "$INSTALL_DIR"

      echo "🚀 Starting text-generation-webui..."
      echo "   Web UI: http://localhost:7860"
      echo "   API: http://localhost:5000"
      echo ""
      echo "Press Ctrl+C to stop"
      echo ""

      source venv/bin/activate
      python server.py \
        --listen \
        --api \
        --extensions api \
        --n-gpu-layers 999 \
        --gpu-memory 90
    '')

    (writeShellScriptBin "qalarc-textgen-cli" ''
      #!/bin/sh
      # CLI interface to text-generation-webui API
      # Usage: qalarc-textgen-cli "Your prompt here"

      if [ $# -lt 1 ]; then
        echo "Usage: qalarc-textgen-cli \"prompt\""
        echo ""
        echo "Example:"
        echo "  qalarc-textgen-cli 'Write a Python function to calculate fibonacci'"
        exit 1
      fi

      PROMPT="$1"
      API_URL="http://localhost:5000/api/v1/generate"

      # Check if API is running
      if ! curl -s "$API_URL" >/dev/null 2>&1; then
        echo "❌ text-generation-webui API not running"
        echo "   Start with: qalarc-start-textgen-webui"
        exit 1
      fi

      echo "🤖 Generating response..."
      echo ""

      curl -s -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -d "{
          \"prompt\": \"$PROMPT\",
          \"max_new_tokens\": 500,
          \"temperature\": 0.7,
          \"top_p\": 0.9
        }" | ${pkgs.jq}/bin/jq -r '.results[0].text'
    '')

    # ──────────────────────────────────────────────────────────
    # 4. MODEL DOWNLOAD HELPERS
    # ──────────────────────────────────────────────────────────

    (writeShellScriptBin "qalarc-download-model" ''
      #!/bin/sh
      # Download models from HuggingFace
      # Usage: qalarc-download-model <repo/model>

      if [ $# -lt 1 ]; then
        echo "Usage: qalarc-download-model <repo/model>"
        echo ""
        echo "Examples:"
        echo "  qalarc-download-model Qwen/Qwen2.5-Coder-32B-Instruct-GGUF"
        echo "  qalarc-download-model TheBloke/deepseek-coder-33B-GGUF"
        echo ""
        echo "Downloads to: /local-llms/huggingface/hub/"
        exit 1
      fi

      MODEL="$1"

      echo "📥 Downloading $MODEL from HuggingFace..."
      echo "   Target: /local-llms/huggingface/hub/"
      echo ""

      ${pkgs.huggingface-cli}/bin/huggingface-cli download \
        "$MODEL" \
        --local-dir /local-llms/huggingface/hub/$(echo "$MODEL" | tr '/' '_') \
        --local-dir-use-symlinks False

      echo ""
      echo "✅ Download complete!"
    '')

    # ──────────────────────────────────────────────────────────
    # 5. UNIFIED AI STATUS COMMAND
    # ──────────────────────────────────────────────────────────

    (writeShellScriptBin "qalarc-ai-status" ''
      #!/bin/sh
      # Comprehensive AI system status

      echo "╔════════════════════════════════════════════════════════════╗"
      echo "║           QALARC AI System Status                          ║"
      echo "╚════════════════════════════════════════════════════════════╝"
      echo ""

      # GPU
      echo "━━━ GPU (AMD Radeon 8060S) ━━━"
      ${pkgs.rocmPackages.rocm-smi}/bin/rocm-smi --showuse --showmeminfo vram 2>/dev/null | head -8
      echo ""

      # Ollama
      echo "━━━ Ollama ━━━"
      if systemctl is-active ollama >/dev/null 2>&1; then
        echo "✅ Running - http://localhost:11434"
        ${pkgs.ollama}/bin/ollama list 2>/dev/null | head -5
      else
        echo "❌ Not running"
      fi
      echo ""

      # text-generation-webui
      echo "━━━ Text Generation WebUI ━━━"
      if [ -d /local-llms/text-generation-webui ]; then
        if curl -s http://localhost:7860 >/dev/null 2>&1; then
          echo "✅ Running - http://localhost:7860"
        else
          echo "⚪ Installed, not running"
          echo "   Start with: qalarc-start-textgen-webui"
        fi
      else
        echo "⚪ Not installed"
        echo "   Install with: qalarc-setup-textgen-webui"
      fi
      echo ""

      # Models
      echo "━━━ Model Storage ━━━"
      if [ -d /local-llms ]; then
        du -sh /local-llms/* 2>/dev/null | head -5
      else
        echo "No models directory"
      fi

      echo ""
      echo "Quick start:"
      echo "  qalarc-ollama-chat           # Ollama CLI chat"
      echo "  qalarc-start-textgen-webui   # Start web UI"
      echo "  qalarc-ai-workspace          # Full TMUX workspace"
    '')
  ];

  # ═══════════════════════════════════════════════════════════
  # DIRECTORY STRUCTURE
  # ═══════════════════════════════════════════════════════════

  systemd.tmpfiles.rules = [
    "d /local-llms 0755 qalarc users -"
    "d /local-llms/ollama 0755 qalarc users -"
    "d /local-llms/huggingface 0755 qalarc users -"
    "d /local-llms/gguf-models 0755 qalarc users -"
    "d /var/lib/qalarc 0755 root root -"
  ];

  # ═══════════════════════════════════════════════════════════
  # GPU STATS EXPORT (for AI assistants)
  # ═══════════════════════════════════════════════════════════

  systemd.services.gpu-stats-export = {
    description = "Export GPU statistics for AI assistant consumption";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "export-gpu-stats" ''
        #!/bin/sh
        ${pkgs.rocmPackages.rocm-smi}/bin/rocm-smi --showuse --showmeminfo --showtemp --json > /tmp/gpu-stats.json 2>/dev/null
        ${pkgs.jq}/bin/jq . /tmp/gpu-stats.json > /var/lib/qalarc/gpu-stats.json 2>/dev/null || true
      '';
    };
  };

  systemd.timers.gpu-stats-export = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
    };
  };

  # ═══════════════════════════════════════════════════════════
  # CLI AI ASSISTANT NOTES
  # ═══════════════════════════════════════════════════════════

  # Command reference for AI coding assistants:
  #
  # OLLAMA (CLI):
  #   - Chat: qalarc-ollama-chat [model]
  #   - Status: qalarc-ollama-status
  #   - One-shot: ollama run model "prompt"
  #   - API: curl http://localhost:11434/api/generate -d '{"model":"...","prompt":"..."}'
  #
  # LLAMA.CPP (Direct):
  #   - Interactive: qalarc-llama /path/to/model.gguf
  #   - One-shot: qalarc-llama model.gguf "prompt"
  #
  # TEXT-GENERATION-WEBUI:
  #   - Setup: qalarc-setup-textgen-webui
  #   - Start: qalarc-start-textgen-webui
  #   - CLI: qalarc-textgen-cli "prompt"
  #   - Web: http://localhost:7860
  #   - API: http://localhost:5000/api/v1/
  #
  # NEOVIM PLUGINS:
  #   - llama.vim: Inline completion in Vim
  #   - codecompanion.nvim: Chat + code actions
  #   - avante.nvim: Cursor-like interface
  #
  # MODELS:
  #   - Download: qalarc-download-model repo/model
  #   - Location: /local-llms/
  #
  # STATUS:
  #   - Full status: qalarc-ai-status
  #   - GPU only: rocm-smi
  #   - System: cat /var/lib/qalarc/gpu-stats.json
}
