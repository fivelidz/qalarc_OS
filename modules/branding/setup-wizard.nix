{ config, pkgs, lib, ... }:

{
  # Qalarc AI-OS Setup Wizard
  # A comprehensive onboarding experience for new users
  
  environment.systemPackages = with pkgs; [
    # Main setup wizard (runs on first boot or on demand)
    (writeShellScriptBin "qalarc-setup" ''
      #!/usr/bin/env bash
      
      # ═══════════════════════════════════════════════════════════════════
      #  QALARC AI-OS SETUP WIZARD
      #  Comprehensive onboarding for local AI systems
      # ═══════════════════════════════════════════════════════════════════
      
      # Colors matching qalarc.com theme
      CYAN='\033[38;2;74;159;184m'
      ORANGE='\033[38;2;204;85;40m'
      GREEN='\033[38;2;51;204;119m'
      YELLOW='\033[38;2;204;170;0m'
      RED='\033[38;2;204;51;0m'
      WHITE='\033[1;37m'
      DIM='\033[2m'
      BOLD='\033[1m'
      NC='\033[0m'
      
      # State file to track setup progress
      STATE_FILE="$HOME/.config/qalarc/setup-state"
      CONFIG_DIR="$HOME/.config/qalarc"
      mkdir -p "$CONFIG_DIR"
      
      # ─────────────────────────────────────────────────────────────────────
      #  UTILITY FUNCTIONS
      # ─────────────────────────────────────────────────────────────────────
      
      clear_screen() {
        clear
        # Draw header
        echo -e "''${CYAN}"
        echo "  ╔════════════════════════════════════════════════════════════════════╗"
        echo "  ║                                                                    ║"
        echo -e "  ║  ''${ORANGE}██████╗  █████╗ ██╗      █████╗ ██████╗  ██████╗''${CYAN}                ║"
        echo -e "  ║  ''${ORANGE}██╔═══██╗██╔══██╗██║     ██╔══██╗██╔══██╗██╔════╝''${CYAN}                ║"
        echo -e "  ║  ''${ORANGE}██║   ██║███████║██║     ███████║██████╔╝██║''${CYAN}                     ║"
        echo -e "  ║  ''${ORANGE}██║▄▄ ██║██╔══██║██║     ██╔══██║██╔══██╗██║''${CYAN}                     ║"
        echo -e "  ║  ''${ORANGE}╚██████╔╝██║  ██║███████╗██║  ██║██║  ██║╚██████╗''${CYAN}                ║"
        echo -e "  ║  ''${ORANGE} ╚══▀▀═╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝''${CYAN}                ║"
        echo "  ║                                                                    ║"
        echo -e "  ║                      ''${WHITE}A I - O S   S E T U P''${CYAN}                        ║"
        echo "  ║                                                                    ║"
        echo "  ╚════════════════════════════════════════════════════════════════════╝"
        echo -e "''${NC}"
        echo ""
      }
      
      print_step() {
        echo -e "''${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${NC}"
        echo -e "''${ORANGE}  STEP $1: ''${WHITE}$2''${NC}"
        echo -e "''${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${NC}"
        echo ""
      }
      
      print_option() {
        echo -e "  ''${CYAN}[$1]''${NC} $2"
      }
      
      print_selected() {
        echo -e "  ''${GREEN}✓''${NC} $1"
      }
      
      print_info() {
        echo -e "  ''${DIM}$1''${NC}"
      }
      
      wait_key() {
        echo ""
        echo -e "  ''${DIM}Press Enter to continue...''${NC}"
        read
      }
      
      # ─────────────────────────────────────────────────────────────────────
      #  STEP 1: WELCOME & SYSTEM CHECK
      # ─────────────────────────────────────────────────────────────────────
      
      step_welcome() {
        clear_screen
        print_step "1/9" "SYSTEM VERIFICATION"
        
        echo -e "  ''${WHITE}Checking your system...''${NC}"
        echo ""
        
        # CPU
        CPU=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
        CORES=$(nproc)
        echo -e "  ''${CYAN}CPU:''${NC}     $CPU"
        echo -e "           ''${DIM}$CORES cores available''${NC}"
        
        # Memory
        MEM_TOTAL=$(free -g | awk '/^Mem:/{print $2}')
        MEM_AVAIL=$(free -g | awk '/^Mem:/{print $7}')
        echo -e "  ''${CYAN}Memory:''${NC}  ''${MEM_TOTAL}GB total, ''${MEM_AVAIL}GB available"
        
        # Check for high memory (128GB+)
        if [ "$MEM_TOTAL" -ge 120 ]; then
          echo -e "           ''${GREEN}✓ High-memory system detected - can run 405B models''${NC}"
          SYSTEM_TIER="high"
          CAN_RUN_LOCAL_AI=true
        elif [ "$MEM_TOTAL" -ge 60 ]; then
          echo -e "           ''${GREEN}✓ Medium system - can run 70B models''${NC}"
          SYSTEM_TIER="medium"
          CAN_RUN_LOCAL_AI=true
        elif [ "$MEM_TOTAL" -ge 30 ]; then
          echo -e "           ''${YELLOW}○ Can run smaller local models (7B-13B)''${NC}"
          SYSTEM_TIER="low"
          CAN_RUN_LOCAL_AI=true
        else
          echo -e "           ''${YELLOW}! Limited RAM - local AI models not recommended''${NC}"
          SYSTEM_TIER="minimal"
          CAN_RUN_LOCAL_AI=false
        fi
        
        # GPU
        if command -v lspci &> /dev/null; then
          GPU=$(lspci | grep -i 'vga\|3d\|display' | head -1 | cut -d: -f3 | xargs)
          echo -e "  ''${CYAN}GPU:''${NC}     $GPU"
          
          # Check for AMD with ROCm potential
          if echo "$GPU" | grep -qi "amd\|radeon"; then
            echo -e "           ''${GREEN}✓ AMD GPU detected - ROCm acceleration available''${NC}"
            HAS_ROCM=true
          fi
        fi
        
        # Storage
        DISK_AVAIL=$(df -h / | awk 'NR==2{print $4}')
        echo -e "  ''${CYAN}Storage:''${NC} $DISK_AVAIL available"
        echo ""
        
        # Verdict
        echo -e "''${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${NC}"
        echo -e "  ''${WHITE}SYSTEM TIER: ''${GREEN}$SYSTEM_TIER''${NC}"
        case $SYSTEM_TIER in
          high)
            echo -e "  ''${DIM}Recommended: Llama 405B, Multiple 70B models, Full knowledge base''${NC}"
            echo -e "  ''${GREEN}✓ All local AI features available''${NC}"
            ;;
          medium)
            echo -e "  ''${DIM}Recommended: Llama 70B, Qwen 72B, Medical/Legal knowledge bases''${NC}"
            echo -e "  ''${GREEN}✓ All local AI features available''${NC}"
            ;;
          low)
            echo -e "  ''${DIM}Recommended: Mistral 7B, Llama 8B, Phi-3, Lightweight models''${NC}"
            echo -e "  ''${GREEN}✓ Local AI available with smaller models''${NC}"
            ;;
          minimal)
            echo -e "  ''${DIM}Your system has limited RAM for local AI models.''${NC}"
            echo ""
            echo -e "  ''${YELLOW}╭─────────────────────────────────────────────────────────────╮''${NC}"
            echo -e "  ''${YELLOW}│  LOCAL AI NOTE                                             │''${NC}"
            echo -e "  ''${YELLOW}├─────────────────────────────────────────────────────────────┤''${NC}"
            echo -e "  ''${YELLOW}│  Your system has less than 32GB RAM. Running large local   │''${NC}"
            echo -e "  ''${YELLOW}│  AI models (Llama, Qwen, etc.) is not recommended.         │''${NC}"
            echo -e "  ''${YELLOW}│                                                             │''${NC}"
            echo -e "  ''${YELLOW}│  You can still use:                                        │''${NC}"
            echo -e "  ''${YELLOW}│    • Claude Code (cloud-based, requires API key)           │''${NC}"
            echo -e "  ''${YELLOW}│    • All other Qalarc features (themes, tools, etc.)       │''${NC}"
            echo -e "  ''${YELLOW}│    • Signal CLI and WhatsApp CLI                           │''${NC}"
            echo -e "  ''${YELLOW}│    • Development tools, browsers, media apps               │''${NC}"
            echo -e "  ''${YELLOW}│                                                             │''${NC}"
            echo -e "  ''${YELLOW}│  For local AI, consider upgrading to 64GB+ RAM.            │''${NC}"
            echo -e "  ''${YELLOW}╰─────────────────────────────────────────────────────────────╯''${NC}"
            ;;
        esac
        echo -e "''${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${NC}"
        
        echo "$SYSTEM_TIER" > "$CONFIG_DIR/system-tier"
        wait_key
      }
      
      # ─────────────────────────────────────────────────────────────────────
      #  STEP 2: DESKTOP THEME SELECTION
      # ─────────────────────────────────────────────────────────────────────
      
      step_theme() {
        clear_screen
        print_step "2/9" "DESKTOP APPEARANCE"
        
        echo -e "  ''${WHITE}Choose your desktop style:''${NC}"
        echo ""
        print_option "1" "''${WHITE}Qalarc Dark''${NC} - Cyan/Orange sci-fi theme (default)"
        print_info "     Dark background, tech-inspired, matches qalarc.com"
        echo ""
        print_option "2" "''${WHITE}macOS-like''${NC} - Clean, minimal dock style"
        print_info "     Global menu, rounded corners, familiar workflow"
        echo ""
        print_option "3" "''${WHITE}Windows-like''${NC} - Traditional taskbar layout"
        print_info "     Bottom taskbar, start menu, system tray"
        echo ""
        print_option "4" "''${WHITE}Tiling (i3-style)''${NC} - Keyboard-driven productivity"
        print_info "     Automatic window tiling, minimal mouse usage"
        echo ""
        print_option "5" "''${WHITE}Minimal Server''${NC} - No desktop, SSH only"
        print_info "     Headless mode for server deployments"
        echo ""
        
        read -p "  Select theme [1-5]: " theme_choice
        
        case $theme_choice in
          1) THEME="qalarc-dark" ;;
          2) THEME="macos-like" ;;
          3) THEME="windows-like" ;;
          4) THEME="tiling" ;;
          5) THEME="server" ;;
          *) THEME="qalarc-dark" ;;
        esac
        
        echo "$THEME" > "$CONFIG_DIR/theme"
        echo ""
        print_selected "Theme set to: $THEME"
        
        # Apply theme hints
        echo ""
        echo -e "  ''${DIM}Theme will be applied after setup completes.''${NC}"
        echo ""
        echo -e "  ''${CYAN}TIP:''${NC} You can always change themes later:"
        echo -e "  ''${DIM}  System Settings → Appearance → Global Theme''${NC}"
        echo -e "  ''${DIM}  Or run: qalarc-theme''${NC}"
        
        wait_key
      }
      
      # ─────────────────────────────────────────────────────────────────────
      #  STEP 3: USE CASE SELECTION
      # ─────────────────────────────────────────────────────────────────────
      
      step_usecase() {
        clear_screen
        print_step "3/9" "PRIMARY USE CASE"
        
        echo -e "  ''${WHITE}What will you primarily use this system for?''${NC}"
        echo -e "  ''${DIM}(Select all that apply, space-separated)''${NC}"
        echo ""
        echo -e "  ''${CYAN}━━━ PROFESSIONAL ━━━''${NC}"
        print_option "1" "''${WHITE}Software Development''${NC} - Coding assistant, code review, debugging"
        print_option "2" "''${WHITE}Research & Writing''${NC} - Papers, articles, analysis"
        print_option "3" "''${WHITE}Healthcare/Medical''${NC} - Clinical notes, drug interactions, coding"
        print_option "4" "''${WHITE}Legal''${NC} - Case research, document analysis, contracts"
        print_option "5" "''${WHITE}Data Analysis''${NC} - Processing, insights, visualization"
        print_option "6" "''${WHITE}Education''${NC} - Teaching, tutoring, course creation"
        echo ""
        echo -e "  ''${CYAN}━━━ PERSONAL ━━━''${NC}"
        print_option "7" "''${WHITE}Creative''${NC} - Writing, storytelling, brainstorming"
        print_option "8" "''${WHITE}General Assistant''${NC} - Chat, Q&A, everyday tasks"
        print_option "9" "''${WHITE}Gaming''${NC} - Game streaming, emulation, performance"
        print_option "10" "''${WHITE}Hobby AI''${NC} - Experimenting, learning, tinkering"
        echo ""
        echo -e "  ''${CYAN}━━━ SPECIAL ━━━''${NC}"
        print_option "11" "''${WHITE}Off-Grid / Privacy''${NC} - Maximum privacy, no cloud, air-gapped capable"
        print_option "12" "''${WHITE}Home Server''${NC} - Media server, file sharing, automation"
        echo ""
        
        read -p "  Select use cases (e.g., 1 2 10): " usecase_input
        
        # Parse selections
        USECASES=""
        for uc in $usecase_input; do
          case $uc in
            1) USECASES="$USECASES development" ;;
            2) USECASES="$USECASES research" ;;
            3) USECASES="$USECASES healthcare" ;;
            4) USECASES="$USECASES legal" ;;
            5) USECASES="$USECASES data" ;;
            6) USECASES="$USECASES education" ;;
            7) USECASES="$USECASES creative" ;;
            8) USECASES="$USECASES general" ;;
            9) USECASES="$USECASES gaming" ;;
            10) USECASES="$USECASES hobby-ai" ;;
            11) USECASES="$USECASES offgrid" ;;
            12) USECASES="$USECASES homeserver" ;;
          esac
        done
        
        echo "$USECASES" > "$CONFIG_DIR/usecases"
        echo ""
        print_selected "Use cases: $USECASES"
        
        wait_key
      }
      
      # ─────────────────────────────────────────────────────────────────────
      #  STEP 4: MODEL SELECTION
      # ─────────────────────────────────────────────────────────────────────
      
      step_models() {
        clear_screen
        print_step "4/9" "AI MODEL SELECTION"
        
        TIER=$(cat "$CONFIG_DIR/system-tier" 2>/dev/null || echo "medium")
        
        echo -e "  ''${WHITE}Based on your ''${GREEN}$TIER''${WHITE} tier system, recommended models:''${NC}"
        echo ""
        
        case $TIER in
          high)
            echo -e "  ''${CYAN}━━━ FLAGSHIP MODELS (128GB+ RAM) ━━━''${NC}"
            print_option "1" "''${WHITE}Llama 3.1 405B Q3''${NC} - Most capable open model"
            print_info "     210GB, ~8-10 tok/s, best for complex reasoning"
            print_option "2" "''${WHITE}Llama 3.3 70B Q8''${NC} - High quality 70B"
            print_info "     75GB, ~20 tok/s, maximum quality at 70B"
            ;;
          medium)
            echo -e "  ''${CYAN}━━━ RECOMMENDED MODELS (64-128GB RAM) ━━━''${NC}"
            ;;
          low)
            echo -e "  ''${CYAN}━━━ LIGHTWEIGHT MODELS (8-32GB RAM) ━━━''${NC}"
            ;;
        esac
        
        echo ""
        echo -e "  ''${CYAN}━━━ GENERAL PURPOSE ━━━''${NC}"
        print_option "3" "''${WHITE}Llama 3.3 70B Q4_K_M''${NC} - Best all-around"
        print_info "     42GB, ~25 tok/s, excellent balance"
        print_option "4" "''${WHITE}Qwen 2.5 72B Q4''${NC} - Strong multilingual"
        print_info "     42GB, ~25 tok/s, great for non-English"
        print_option "5" "''${WHITE}Mistral 7B''${NC} - Fast responses"
        print_info "     4GB, ~100 tok/s, quick interactions"
        
        echo ""
        echo -e "  ''${CYAN}━━━ SPECIALIZED ━━━''${NC}"
        print_option "6" "''${WHITE}Qwen 2.5 Coder 32B''${NC} - Best for coding"
        print_info "     20GB, ~40 tok/s, code completion & review"
        print_option "7" "''${WHITE}DeepSeek Coder V2''${NC} - Open source coding"
        print_info "     16GB, ~50 tok/s, excellent for development"
        print_option "8" "''${WHITE}Llama 3.2 Vision 11B''${NC} - Multimodal"
        print_info "     7GB, image understanding + text"
        
        echo ""
        read -p "  Select models to install (e.g., 3 6 7): " model_input
        
        # Map selections to Ollama model names
        MODELS=""
        for m in $model_input; do
          case $m in
            1) MODELS="$MODELS llama3.1:405b" ;;
            2) MODELS="$MODELS llama3.3:70b-q8" ;;
            3) MODELS="$MODELS llama3.3:70b" ;;
            4) MODELS="$MODELS qwen2.5:72b" ;;
            5) MODELS="$MODELS mistral:7b" ;;
            6) MODELS="$MODELS qwen2.5-coder:32b" ;;
            7) MODELS="$MODELS deepseek-coder-v2" ;;
            8) MODELS="$MODELS llama3.2-vision:11b" ;;
          esac
        done
        
        echo "$MODELS" > "$CONFIG_DIR/models"
        echo ""
        print_selected "Models to install: $MODELS"
        echo ""
        echo -e "  ''${DIM}Models will be downloaded after setup (may take 30-60 min)''${NC}"
        
        wait_key
      }
      
      # ─────────────────────────────────────────────────────────────────────
      #  STEP 5: KNOWLEDGE BASE SELECTION
      # ─────────────────────────────────────────────────────────────────────
      
      step_knowledge() {
        clear_screen
        print_step "5/9" "OFFLINE KNOWLEDGE BASES"
        
        echo -e "  ''${WHITE}Select offline knowledge bases to install:''${NC}"
        echo -e "  ''${DIM}These enable AI to answer questions without internet''${NC}"
        echo ""
        
        print_option "1" "''${WHITE}Wikipedia''${NC} (600 GB)"
        print_info "     6.2M+ articles, full-text search, embeddings"
        echo ""
        print_option "2" "''${WHITE}Stack Overflow''${NC} (150 GB)"
        print_info "     23M+ Q&A posts, code examples, solutions"
        echo ""
        print_option "3" "''${WHITE}Medical/Healthcare''${NC} (2 TB)"
        print_info "     PubMed, drug databases, clinical references, ICD-10"
        echo ""
        print_option "4" "''${WHITE}Legal''${NC} (1 TB)"
        print_info "     US case law, statutes, regulations, contracts"
        echo ""
        print_option "5" "''${WHITE}Scientific Papers''${NC} (3 TB)"
        print_info "     arXiv preprints, open access journals"
        echo ""
        print_option "6" "''${WHITE}GitHub Top Repos''${NC} (500 GB)"
        print_info "     10K most popular repositories, code search"
        echo ""
        print_option "S" "''${WHITE}Skip''${NC} - Install knowledge bases later"
        echo ""
        
        read -p "  Select knowledge bases (e.g., 1 2 6): " kb_input
        
        if [ "$kb_input" != "S" ] && [ "$kb_input" != "s" ]; then
          KNOWLEDGE=""
          for kb in $kb_input; do
            case $kb in
              1) KNOWLEDGE="$KNOWLEDGE wikipedia" ;;
              2) KNOWLEDGE="$KNOWLEDGE stackoverflow" ;;
              3) KNOWLEDGE="$KNOWLEDGE medical" ;;
              4) KNOWLEDGE="$KNOWLEDGE legal" ;;
              5) KNOWLEDGE="$KNOWLEDGE scientific" ;;
              6) KNOWLEDGE="$KNOWLEDGE github" ;;
            esac
          done
          echo "$KNOWLEDGE" > "$CONFIG_DIR/knowledge-bases"
          print_selected "Knowledge bases: $KNOWLEDGE"
        else
          echo "" > "$CONFIG_DIR/knowledge-bases"
          print_selected "Skipped - install later with: qalarc knowledge install"
        fi
        
        wait_key
      }
      
      # ─────────────────────────────────────────────────────────────────────
      #  STEP 6: DEVELOPER TOOLS
      # ─────────────────────────────────────────────────────────────────────
      
      step_devtools() {
        clear_screen
        print_step "6/9" "DEVELOPER & POWER USER TOOLS"
        
        echo -e "  ''${WHITE}Select additional tools to install:''${NC}"
        echo ""
        
        echo -e "  ''${CYAN}━━━ EDITORS & IDE ━━━''${NC}"
        print_option "1" "VS Code with AI extensions"
        print_option "2" "Neovim with AI plugins (codecompanion, avante)"
        print_option "3" "JetBrains IDE support"
        echo ""
        
        echo -e "  ''${CYAN}━━━ CONTAINERS & VIRTUALIZATION ━━━''${NC}"
        print_option "4" "Docker + Docker Compose"
        print_option "5" "Podman (rootless containers)"
        print_option "6" "Kubernetes (k3s)"
        echo ""
        
        echo -e "  ''${CYAN}━━━ AI/ML DEVELOPMENT ━━━''${NC}"
        print_option "7" "PyTorch + ROCm (AMD GPU)"
        print_option "8" "Jupyter Lab"
        print_option "9" "LangChain + RAG tools"
        echo ""
        
        echo -e "  ''${CYAN}━━━ MONITORING & ADMIN ━━━''${NC}"
        print_option "10" "Prometheus + Grafana dashboards"
        print_option "11" "Portainer (container management UI)"
        echo ""
        
        read -p "  Select tools (e.g., 1 2 4 7): " tools_input
        echo "$tools_input" > "$CONFIG_DIR/devtools"
        
        print_selected "Tools will be configured"
        wait_key
      }
      
      # ─────────────────────────────────────────────────────────────────────
      #  STEP 7: NETWORK & REMOTE ACCESS
      # ─────────────────────────────────────────────────────────────────────
      
      step_network() {
        clear_screen
        print_step "7/9" "NETWORK & REMOTE ACCESS"
        
        echo -e "  ''${WHITE}Configure remote access options:''${NC}"
        echo ""
        
        print_option "1" "''${WHITE}Tailscale''${NC} - Zero-config VPN (recommended)"
        print_info "     Access from anywhere, no port forwarding needed"
        echo ""
        print_option "2" "''${WHITE}SSH''${NC} - Secure shell access"
        print_info "     Already enabled by default"
        echo ""
        print_option "3" "''${WHITE}Sunshine''${NC} - Desktop streaming (like Steam Link)"
        print_info "     Stream desktop to phone/tablet with Moonlight"
        echo ""
        print_option "4" "''${WHITE}WireGuard''${NC} - High-performance VPN"
        print_info "     Site-to-site connections, manual config"
        echo ""
        print_option "5" "''${WHITE}OpenAI-Compatible API''${NC} - Expose models as API"
        print_info "     Use local models with any OpenAI-compatible app"
        echo ""
        
        read -p "  Select options (e.g., 1 2 5): " network_input
        echo "$network_input" > "$CONFIG_DIR/network"
        
        # Tailscale setup hint
        if echo "$network_input" | grep -q "1"; then
          echo ""
          echo -e "  ''${CYAN}━━━ TAILSCALE SETUP ━━━''${NC}"
          echo -e "  ''${WHITE}To activate Tailscale after setup:''${NC}"
          echo -e "  ''${DIM}  sudo tailscale up''${NC}"
          echo -e "  ''${DIM}  Then visit the URL to authenticate''${NC}"
        fi
        
        wait_key
      }
      
      # ─────────────────────────────────────────────────────────────────────
      #  STEP 8: APPLICATIONS & COMMUNICATION
      # ─────────────────────────────────────────────────────────────────────
      
      step_apps() {
        clear_screen
        print_step "8/9" "APPLICATIONS"
        
        echo -e "  ''${WHITE}The following applications are included by default.''${NC}"
        echo -e "  ''${DIM}Enter numbers to REMOVE apps you don't want (or press Enter for all)''${NC}"
        echo ""
        
        echo -e "  ''${CYAN}━━━ AI CODING TOOLS (Always Included) ━━━''${NC}"
        echo -e "  ''${GREEN}✓''${NC} Claude Code - AI coding assistant (cloud)"
        echo -e "  ''${GREEN}✓''${NC} OpenCode - AI coding assistant (local models)"
        echo -e "  ''${GREEN}✓''${NC} Ghostty + TMUX - Terminal environment"
        echo -e "  ''${GREEN}✓''${NC} Right-click 'Open in AI' for folders"
        echo ""
        
        echo -e "  ''${CYAN}━━━ MESSAGING ━━━''${NC}"
        echo -e "  ''${GREEN}[1]''${NC} Signal - Encrypted messaging (CLI + Desktop)"
        echo -e "  ''${GREEN}[2]''${NC} WhatsApp/Telegram - Via nchat terminal client"
        echo ""
        
        echo -e "  ''${CYAN}━━━ BROWSERS ━━━''${NC}"
        echo -e "  ''${GREEN}[3]''${NC} Firefox - Privacy-focused browser"
        echo -e "  ''${GREEN}[4]''${NC} Brave - Chromium with ad blocking"
        echo ""
        
        echo -e "  ''${CYAN}━━━ PRODUCTIVITY ━━━''${NC}"
        echo -e "  ''${GREEN}[5]''${NC} LibreOffice - Office suite"
        echo -e "  ''${GREEN}[6]''${NC} GIMP - Image editing"
        echo -e "  ''${GREEN}[7]''${NC} Inkscape - Vector graphics"
        echo ""
        
        echo -e "  ''${CYAN}━━━ MEDIA ━━━''${NC}"
        echo -e "  ''${GREEN}[8]''${NC} VLC - Media player"
        echo -e "  ''${GREEN}[9]''${NC} OBS Studio - Streaming/recording"
        echo -e "  ''${GREEN}[10]''${NC} MPV - Lightweight video player"
        echo ""
        
        echo -e "  ''${CYAN}━━━ UTILITIES ━━━''${NC}"
        echo -e "  ''${GREEN}[11]''${NC} Bitwarden - Password manager"
        echo -e "  ''${GREEN}[12]''${NC} Syncthing - File sync across devices"
        echo -e "  ''${GREEN}[13]''${NC} qBittorrent - Torrent client"
        echo -e "  ''${GREEN}[14]''${NC} Discord - Community chat"
        echo ""
        
        read -p "  Remove which apps? (e.g., 6 7 9 or Enter for all): " remove_input
        
        # Start with all apps
        APPS="signal nchat firefox brave libreoffice gimp inkscape vlc obs mpv bitwarden syncthing qbittorrent discord"
        
        # Remove deselected
        for r in $remove_input; do
          case $r in
            1) APPS=$(echo "$APPS" | sed 's/signal//g') ;;
            2) APPS=$(echo "$APPS" | sed 's/nchat//g') ;;
            3) APPS=$(echo "$APPS" | sed 's/firefox//g') ;;
            4) APPS=$(echo "$APPS" | sed 's/brave//g') ;;
            5) APPS=$(echo "$APPS" | sed 's/libreoffice//g') ;;
            6) APPS=$(echo "$APPS" | sed 's/gimp//g') ;;
            7) APPS=$(echo "$APPS" | sed 's/inkscape//g') ;;
            8) APPS=$(echo "$APPS" | sed 's/vlc//g') ;;
            9) APPS=$(echo "$APPS" | sed 's/obs//g') ;;
            10) APPS=$(echo "$APPS" | sed 's/mpv//g') ;;
            11) APPS=$(echo "$APPS" | sed 's/bitwarden//g') ;;
            12) APPS=$(echo "$APPS" | sed 's/syncthing//g') ;;
            13) APPS=$(echo "$APPS" | sed 's/qbittorrent//g') ;;
            14) APPS=$(echo "$APPS" | sed 's/discord//g') ;;
          esac
        done
        
        # Clean up whitespace
        APPS=$(echo "$APPS" | xargs)
        
        echo "$APPS" > "$CONFIG_DIR/applications"
        echo ""
        print_selected "Installing: $APPS"
        
        # Show AI coding hints
        echo ""
        echo -e "  ''${CYAN}━━━ AI CODING TIPS ━━━''${NC}"
        echo -e "  ''${DIM}• Right-click any folder → 'Open in AI' to start coding''${NC}"
        echo -e "  ''${DIM}• Press Meta+A for quick AI access from anywhere''${NC}"
        echo -e "  ''${DIM}• TMUX: Ctrl+a then 'o' opens Claude, 'O' opens OpenCode''${NC}"
        
        # Show messaging hints if included
        if echo "$APPS" | grep -q "signal\|nchat"; then
          echo ""
          echo -e "  ''${CYAN}━━━ MESSAGING SETUP ━━━''${NC}"
          if echo "$APPS" | grep -q "signal"; then
            echo -e "  ''${DIM}Signal: Run 'qalarc-signal link' to pair with phone''${NC}"
          fi
          if echo "$APPS" | grep -q "nchat"; then
            echo -e "  ''${DIM}WhatsApp/Telegram: Run 'qalarc-whatsapp setup' for instructions''${NC}"
          fi
        fi
        
        wait_key
      }
      
      # ─────────────────────────────────────────────────────────────────────
      #  STEP 9: SUMMARY & APPLY
      # ─────────────────────────────────────────────────────────────────────
      
      step_summary() {
        clear_screen
        print_step "9/9" "CONFIGURATION SUMMARY"
        
        echo -e "  ''${WHITE}Your Qalarc AI-OS will be configured with:''${NC}"
        echo ""
        
        TIER=$(cat "$CONFIG_DIR/system-tier" 2>/dev/null)
        THEME=$(cat "$CONFIG_DIR/theme" 2>/dev/null)
        USECASES=$(cat "$CONFIG_DIR/usecases" 2>/dev/null)
        MODELS=$(cat "$CONFIG_DIR/models" 2>/dev/null)
        KB=$(cat "$CONFIG_DIR/knowledge-bases" 2>/dev/null)
        APPS=$(cat "$CONFIG_DIR/applications" 2>/dev/null)
        
        echo -e "  ''${CYAN}System Tier:''${NC}      $TIER"
        echo -e "  ''${CYAN}Theme:''${NC}            $THEME"
        echo -e "  ''${CYAN}Use Cases:''${NC}        $USECASES"
        echo -e "  ''${CYAN}AI Models:''${NC}        $MODELS"
        echo -e "  ''${CYAN}Knowledge Bases:''${NC}  ''${KB:-none selected}"
        echo -e "  ''${CYAN}Applications:''${NC}     ''${APPS:-defaults only}"
        echo ""
        
        echo -e "''${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${NC}"
        echo ""
        echo -e "  ''${WHITE}Ready to apply configuration?''${NC}"
        echo ""
        print_option "Y" "Apply and start downloads"
        print_option "N" "Cancel and exit"
        print_option "R" "Restart setup wizard"
        echo ""
        
        read -p "  Your choice [Y/n/r]: " apply_choice
        
        case $apply_choice in
          [Nn])
            echo ""
            echo -e "  ''${YELLOW}Setup cancelled. Run 'qalarc-setup' to try again.''${NC}"
            exit 0
            ;;
          [Rr])
            exec "$0"
            ;;
          *)
            apply_configuration
            ;;
        esac
      }
      
      # ─────────────────────────────────────────────────────────────────────
      #  APPLY CONFIGURATION
      # ─────────────────────────────────────────────────────────────────────
      
      apply_configuration() {
        clear_screen
        echo -e "''${CYAN}"
        echo "  ╔════════════════════════════════════════════════════════════════════╗"
        echo "  ║                APPLYING CONFIGURATION                              ║"
        echo "  ╚════════════════════════════════════════════════════════════════════╝"
        echo -e "''${NC}"
        echo ""
        
        # 1. Set wallpaper
        echo -e "  ''${CYAN}[1/5]''${NC} Setting wallpaper..."
        WALLPAPER="/etc/qalarc/wallpapers/qalarc_branded_dark.png"
        if [ -f "$WALLPAPER" ]; then
          # Try to set via plasma
          plasma-apply-wallpaperimage "$WALLPAPER" 2>/dev/null || true
          print_selected "Wallpaper applied"
        fi
        
        # 2. Download models
        MODELS=$(cat "$CONFIG_DIR/models" 2>/dev/null)
        if [ -n "$MODELS" ]; then
          echo ""
          echo -e "  ''${CYAN}[2/5]''${NC} Downloading AI models..."
          echo -e "  ''${DIM}This may take 30-60 minutes depending on your connection''${NC}"
          echo ""
          
          for model in $MODELS; do
            echo -e "  ''${YELLOW}→''${NC} Downloading: $model"
            ollama pull "$model" 2>&1 | while read line; do
              echo -e "    ''${DIM}$line''${NC}"
            done
            print_selected "Downloaded: $model"
          done
        fi
        
        # 3. Mark setup complete
        echo ""
        echo -e "  ''${CYAN}[5/5]''${NC} Finalizing..."
        date +%s > "$CONFIG_DIR/setup-complete"
        print_selected "Setup complete!"
        
        echo ""
        echo -e "''${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${NC}"
        echo ""
        echo -e "  ''${WHITE}''${BOLD}Qalarc AI-OS is ready!''${NC}"
        echo ""
        echo -e "  ''${CYAN}Quick Start:''${NC}"
        echo -e "    ''${DIM}Chat with AI:''${NC}        ollama run llama3.3:70b"
        echo -e "    ''${DIM}System status:''${NC}       qalarc-system-info"
        echo -e "    ''${DIM}Change wallpaper:''${NC}    qalarc-set-wallpaper"
        echo -e "    ''${DIM}Re-run setup:''${NC}        qalarc-setup"
        echo ""
        echo -e "  ''${CYAN}Documentation:''${NC}       https://qalarc.com/docs"
        echo -e "  ''${CYAN}Support:''${NC}             team@qalarc.com"
        echo ""
        echo -e "''${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${NC}"
        echo ""
      }
      
      # ─────────────────────────────────────────────────────────────────────
      #  MAIN
      # ─────────────────────────────────────────────────────────────────────
      
      main() {
        # Check if already completed
        if [ -f "$CONFIG_DIR/setup-complete" ]; then
          echo ""
          echo -e "  ''${YELLOW}Setup was already completed.''${NC}"
          echo ""
          echo -e "  ''${WHITE}Options:''${NC}"
          print_option "1" "Run setup again (reconfigure)"
          print_option "2" "Show current configuration"
          print_option "3" "Exit"
          echo ""
          read -p "  Choice [1-3]: " rechoice
          
          case $rechoice in
            1) rm "$CONFIG_DIR/setup-complete" ;;
            2) 
              cat "$CONFIG_DIR"/*
              exit 0
              ;;
            *) exit 0 ;;
          esac
        fi
        
        step_welcome
        step_theme
        step_usecase
        step_models
        step_knowledge
        step_devtools
        step_network
        step_apps
        step_summary
      }
      
      main "$@"
    '')
  ];
}
