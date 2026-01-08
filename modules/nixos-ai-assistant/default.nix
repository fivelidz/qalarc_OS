{ config, pkgs, lib, ... }:

{
  # NixOS AI Assistant Module
  # Provides AI-powered help for NixOS configuration and troubleshooting
  # with comprehensive context library stored in /context/nixos/

  environment.systemPackages = with pkgs; [
    # Core AI assistant tools
    python312
    python312Packages.pip
    uv   # Modern Python package manager (includes uvx)
    git

    # NixOS AI helpers
    (writeShellScriptBin "qalarc-nixos-ai" ''
      #!/usr/bin/env bash
      # Interactive NixOS AI assistant using local context + LLM

      CONTEXT_DIR="/context/nixos"

      # Ensure context directory exists
      mkdir -p "$CONTEXT_DIR"/{docs,packages,examples,discourse,issues}

      echo "╔════════════════════════════════════════════════════════════╗"
      echo "║          qalarc_OS NixOS AI Assistant                     ║"
      echo "╚════════════════════════════════════════════════════════════╝"
      echo ""
      echo "Context library: $CONTEXT_DIR"
      echo "Using: Ollama + RAG + MCP-NixOS"
      echo ""

      if [ "$1" = "ask" ]; then
        shift
        QUESTION="$*"

        # Use Ollama with context injection
        echo "🔍 Searching NixOS context for: $QUESTION"
        echo ""

        # Build context from local docs
        CONTEXT=$(grep -r -i "$QUESTION" "$CONTEXT_DIR" 2>/dev/null | head -20)

        # Query with context
        ollama run qwen2.5-coder:32b <<EOF
You are a NixOS expert assistant. Answer based on this context from the official NixOS documentation and community resources:

CONTEXT:
$CONTEXT

QUESTION: $QUESTION

Provide a clear, practical answer with NixOS configuration examples.
EOF
      elif [ "$1" = "context" ]; then
        echo "📚 NixOS Context Library Status:"
        echo ""
        du -sh "$CONTEXT_DIR"/* 2>/dev/null || echo "Context library not yet populated"
        echo ""
        echo "Run 'qalarc-nixos-update-context' to download/update"
      else
        echo "Usage:"
        echo "  qalarc-nixos-ai ask <question>    # Ask NixOS question"
        echo "  qalarc-nixos-ai context           # Show context status"
        echo ""
        echo "Examples:"
        echo "  qalarc-nixos-ai ask 'How do I enable SSH?'"
        echo "  qalarc-nixos-ai ask 'Configure nginx reverse proxy'"
      fi
    '')

    (writeShellScriptBin "qalarc-nixos-update-context" ''
      #!/usr/bin/env bash
      # Download and update NixOS documentation context library

      CONTEXT_DIR="/context/nixos"
      mkdir -p "$CONTEXT_DIR"/{docs,packages,examples,discourse,issues}

      echo "╔════════════════════════════════════════════════════════════╗"
      echo "║       Updating NixOS Context Library                      ║"
      echo "╚════════════════════════════════════════════════════════════╝"
      echo ""

      # 1. NixOS Manual
      echo "📖 [1/6] Downloading NixOS Manual..."
      if [ ! -d "$CONTEXT_DIR/docs/nixos-manual" ]; then
        git clone --depth 1 https://github.com/NixOS/nixpkgs "$CONTEXT_DIR/docs/nixos-manual" 2>/dev/null
        echo "  ✓ Cloned nixpkgs (contains manual sources)"
      else
        cd "$CONTEXT_DIR/docs/nixos-manual" && git pull
        echo "  ✓ Updated nixpkgs"
      fi

      # 2. Home Manager Manual
      echo "📖 [2/6] Downloading Home Manager docs..."
      if [ ! -d "$CONTEXT_DIR/docs/home-manager" ]; then
        git clone --depth 1 https://github.com/nix-community/home-manager "$CONTEXT_DIR/docs/home-manager"
        echo "  ✓ Cloned home-manager"
      else
        cd "$CONTEXT_DIR/docs/home-manager" && git pull
        echo "  ✓ Updated home-manager"
      fi

      # 3. NixOS Wiki (selected pages)
      echo "📖 [3/6] Downloading NixOS Wiki mirror..."
      if [ ! -d "$CONTEXT_DIR/docs/nixos-wiki" ]; then
        git clone --depth 1 https://github.com/nixos-wiki/nixos-wiki "$CONTEXT_DIR/docs/nixos-wiki" 2>/dev/null || {
          mkdir -p "$CONTEXT_DIR/docs/nixos-wiki"
          echo "  ⚠ Wiki mirror not available, using nixos.wiki scraper"
        }
      fi

      # 4. Example configurations
      echo "📦 [4/6] Downloading example configurations..."
      EXAMPLE_REPOS=(
        "https://github.com/Misterio77/nix-starter-configs:starter-configs"
        "https://github.com/Mic92/dotfiles:mic92-dotfiles"
        "https://github.com/hlissner/dotfiles:hlissner-dotfiles"
      )

      for repo in "''${EXAMPLE_REPOS[@]}"; do
        IFS=':' read -r url name <<< "$repo"
        if [ ! -d "$CONTEXT_DIR/examples/$name" ]; then
          git clone --depth 1 "$url" "$CONTEXT_DIR/examples/$name" 2>/dev/null && \
            echo "  ✓ Cloned $name" || echo "  ⚠ Failed: $name"
        fi
      done

      # 5. NixOS Discourse (top posts - manual download)
      echo "💬 [5/6] NixOS Discourse archive..."
      echo "  ⓘ Discourse posts require manual archiving or API access"
      echo "  ⓘ Consider using https://discourse.nixos.org RSS feeds"

      # 6. Package search cache
      echo "📦 [6/6] Caching package search..."
      nix search nixpkgs --json > "$CONTEXT_DIR/packages/nixpkgs-cache.json" 2>/dev/null && \
        echo "  ✓ Cached nixpkgs search" || echo "  ⚠ Search cache failed"

      echo ""
      echo "✅ Context library updated!"
      echo ""
      echo "📊 Library size:"
      du -sh "$CONTEXT_DIR"
      echo ""
      echo "📚 Contents:"
      find "$CONTEXT_DIR" -maxdepth 2 -type d | sort
    '')

    (writeShellScriptBin "qalarc-nixos-chat" ''
      #!/usr/bin/env bash
      # Interactive NixOS chat with context-aware AI

      MODEL="''${QALARC_NIXOS_MODEL:-qwen2.5-coder:32b}"
      CONTEXT_DIR="/context/nixos"

      echo "╔════════════════════════════════════════════════════════════╗"
      echo "║       NixOS Context-Aware AI Chat                         ║"
      echo "╚════════════════════════════════════════════════════════════╝"
      echo ""
      echo "Model: $MODEL"
      echo "Context: $CONTEXT_DIR"
      echo ""
      echo "Type 'exit' to quit, 'context' to show loaded context"
      echo ""

      # System prompt with NixOS expertise
      SYSTEM_PROMPT="You are a NixOS expert assistant. You have access to:
- Complete NixOS manual and options
- Home Manager documentation
- Real NixOS configurations from expert users
- Package database (130K+ packages)
- Community discussions and solutions

When answering:
1. Provide working NixOS/Nix code examples
2. Explain the declarative approach
3. Reference specific NixOS options when relevant
4. Consider flakes vs legacy nix-channel approaches
5. Mention common pitfalls and best practices

Current system: AMD Ryzen AI Max+ 395 with 96GB UMA VRAM, ROCm for AI/ML"

      # Interactive loop
      while true; do
        echo -n "❯ "
        read -r QUESTION

        [ "$QUESTION" = "exit" ] && break

        if [ "$QUESTION" = "context" ]; then
          echo "📚 Loaded context:"
          find "$CONTEXT_DIR" -type f -name "*.nix" | wc -l | xargs echo "  Nix files:"
          find "$CONTEXT_DIR" -type f -name "*.md" | wc -l | xargs echo "  Markdown docs:"
          continue
        fi

        # Query Ollama with system prompt
        echo ""
        ollama run "$MODEL" <<EOF
$SYSTEM_PROMPT

USER QUESTION: $QUESTION
EOF
        echo ""
      done
    '')

    (writeShellScriptBin "qalarc-nixos-mcp-server" ''
      #!/usr/bin/env bash
      # Start MCP-NixOS server for Claude/other MCP clients

      echo "Starting MCP-NixOS server..."
      echo "This provides access to:"
      echo "  - 130K+ NixOS packages"
      echo "  - 22K+ configuration options"
      echo "  - 4K+ Home Manager options"
      echo ""

      # Check if uvx is available
      if command -v uvx &> /dev/null; then
        echo "Using uvx to run mcp-nixos..."
        uvx mcp-nixos
      elif command -v nix &> /dev/null; then
        echo "Using nix to run mcp-nixos..."
        nix run github:utensils/mcp-nixos --
      else
        echo "❌ Neither uvx nor nix found!"
        echo "Install with: pip install uvx"
        exit 1
      fi
    '')

    (writeShellScriptBin "qalarc-nixos-install-mcp" ''
      #!/usr/bin/env bash
      # Install and configure MCP-NixOS for Claude Code / other MCP clients

      echo "╔════════════════════════════════════════════════════════════╗"
      echo "║      MCP-NixOS Installation for AI Assistants             ║"
      echo "╚════════════════════════════════════════════════════════════╝"
      echo ""

      # Install uvx if not present
      if ! command -v uvx &> /dev/null; then
        echo "Installing uvx..."
        pip install --user uv
        uv tool install uvx
      fi

      # Install mcp-nixos
      echo "Installing mcp-nixos..."
      uvx mcp-nixos --help

      # Create Claude Code MCP config
      MCP_CONFIG="$HOME/.config/claude-code/mcp.json"
      mkdir -p "$(dirname "$MCP_CONFIG")"

      if [ ! -f "$MCP_CONFIG" ]; then
        cat > "$MCP_CONFIG" <<'EOF'
{
  "mcpServers": {
    "nixos": {
      "command": "uvx",
      "args": ["mcp-nixos"]
    }
  }
}
EOF
        echo "✅ Created MCP config at $MCP_CONFIG"
      else
        echo "⚠️  MCP config already exists at $MCP_CONFIG"
        echo "Add this entry manually:"
        echo '  "nixos": { "command": "uvx", "args": ["mcp-nixos"] }'
      fi

      echo ""
      echo "✅ MCP-NixOS installed!"
      echo ""
      echo "Restart Claude Code to enable NixOS context."
    '')

    (writeShellScriptBin "qalarc-nixos-rag-index" ''
      #!/usr/bin/env bash
      # Build RAG vector database from NixOS context

      CONTEXT_DIR="/context/nixos"
      INDEX_DIR="/context/nixos-rag-index"

      echo "╔════════════════════════════════════════════════════════════╗"
      echo "║       Building NixOS RAG Index                            ║"
      echo "╚════════════════════════════════════════════════════════════╝"
      echo ""

      echo "This will create a vector database for fast semantic search"
      echo "across NixOS documentation, examples, and community posts."
      echo ""
      echo "⚠️  Coming soon: Using text-generation-webui extensions"
      echo ""
      echo "For now, use simple grep-based search:"
      echo "  qalarc-nixos-ai ask <question>"
      echo ""
      echo "Future enhancements:"
      echo "  - ChromaDB vector store"
      echo "  - Sentence transformers for embeddings"
      echo "  - Fast semantic search with RAG"
      echo "  - Integration with text-generation-webui"
    '')

    # Installation check helper
    (writeShellScriptBin "qalarc-nixos-ai-status" ''
      #!/usr/bin/env bash

      echo "╔════════════════════════════════════════════════════════════╗"
      echo "║       NixOS AI Assistant Status                           ║"
      echo "╚════════════════════════════════════════════════════════════╝"
      echo ""

      # Check Ollama
      if systemctl is-active --quiet ollama; then
        echo "✅ Ollama service: Running"
        ollama list | head -5
      else
        echo "❌ Ollama service: Not running"
        echo "   Start: sudo systemctl start ollama"
      fi
      echo ""

      # Check MCP
      if command -v uvx &> /dev/null; then
        echo "✅ uvx installed (for MCP-NixOS)"
      else
        echo "⚠️  uvx not installed"
        echo "   Install: qalarc-nixos-install-mcp"
      fi
      echo ""

      # Check context library
      if [ -d "/context/nixos/docs" ]; then
        echo "✅ Context library:"
        du -sh /context/nixos 2>/dev/null
        find /context/nixos -maxdepth 2 -type d | wc -l | xargs echo "   Directories:"
      else
        echo "⚠️  Context library not initialized"
        echo "   Run: qalarc-nixos-update-context"
      fi
      echo ""

      # Check available models
      echo "📦 Available AI models:"
      ollama list 2>/dev/null || echo "   No models downloaded yet"
      echo ""

      echo "💡 Quick start:"
      echo "   qalarc-nixos-ai ask 'How do I configure SSH?'"
      echo "   qalarc-nixos-chat  # Interactive chat"
      echo "   qalarc-nixos-update-context  # Download docs"
    '')
  ];

  # Ensure /context directory structure
  systemd.tmpfiles.rules = [
    "d /context/nixos 0755 root root -"
    "d /context/nixos/docs 0755 root root -"
    "d /context/nixos/packages 0755 root root -"
    "d /context/nixos/examples 0755 root root -"
    "d /context/nixos/discourse 0755 root root -"
    "d /context/nixos/issues 0755 root root -"
  ];

  # Environment variables for AI assistants
  environment.variables = {
    QALARC_NIXOS_CONTEXT = "/context/nixos";
    QALARC_NIXOS_MODEL = "qwen2.5-coder:32b";  # Default model for NixOS help
  };
}
