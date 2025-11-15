# AI Software Research for qalarc_OS

Research findings on AI models, frameworks, and terminal-based coding assistants for AMD Ryzen AI Max+ 395 systems.

**Date:** 2025-11-15
**Hardware:** AMD Ryzen AI Max+ 395 (126 TOPS, 96GB UMA VRAM)
**Focus:** Terminal-based workflows, local LLMs, privacy-first

---

## 🏭 OEM Pre-installed Software

### GMKTEC EVO-X2 AI (Windows 11)

**Pre-installed AI Software:**
- **GMKtec AI Assistant** (v3.2.3+) - Auto-updating application
- Can load **Llama 4 109B** model (~54GB VRAM)
- Pre-configured for **LM Studio** (llama.cpp-based)

**Performance Examples:**
- Qwen3:235B - 11 tokens/s, 0.03s client token time
- Supports 70B models natively

**Documentation:**
- User manual available (manuals.plus/asin/B0FKYZF9HL)
- Windows 11 Pro included
- Linux/Ubuntu compatible (no pre-installed Linux software)

### Framework Laptop (AMD Ryzen AI 300 Series)

**Pre-installed Software:**
- Stock Windows 11 + drivers (minimal bloat)
- Copilot+ support
- No proprietary AI software bundle

**AMD Ryzen AI Software Platform:**
- Official documentation: github.com/amd/ryzen-ai-documentation
- NPU support via XDNA architecture
- Model optimization and deployment tools
- Release 1.6.1 available

### Minisforum MS-S1 MAX

**Pre-installed Software:**
- **NONE** - No AI models or software bundles included
- Hardware-only platform
- Users must download/install AI software separately

**Important:** Minisforum explicitly states "Third-party trademarks are property of their owners. Software compatibility is not supported by MINISFORUM."

---

## 🚀 Recommended AI Stack for qalarc_OS

### Terminal-First Philosophy

**Your stated priority:**
> "Ultimately much of what I want to work with though will be in terminal with an inline coding model. And I might build my own terminal model interface too though for this best."

### Recommended Multi-Tier Approach

#### **Tier 1: Terminal Inline Assistants** (Primary workflow)

1. **llama.vim** / **llama.nvim**
   - Direct llama.cpp integration
   - 100% local, private, offline
   - Resource-efficient
   - Works in Vim/Neovim
   - No API keys needed

2. **codecompanion.nvim**
   - Supports Ollama (local)
   - Multi-backend (Anthropic, OpenAI, local)
   - Agent Client Protocol
   - Terminal-friendly

3. **Custom Terminal Interface**
   - Build on llama.cpp C++ API
   - Direct ROCm integration
   - Optimized for your workflow
   - Full control over UX

#### **Tier 2: Backend Inference Servers** (Supporting services)

1. **Ollama** (Simplicity)
   - REST API for scripts
   - Easy model management
   - Good for automation
   - Limited features vs. alternatives

2. **text-generation-webui** (Feature-rich)
   - Web UI when needed
   - Multiple backends (llama.cpp, ExLlama, Transformers)
   - Extensions (web search, RAG)
   - OpenAI-compatible API
   - **Best for experimentation**

3. **vLLM** (Production)
   - High-performance serving
   - Flash Attention, Paged Attention
   - Multi-GPU tensor parallelism
   - **Best for serving multiple users/apps**

4. **HuggingFace TGI** (Enterprise)
   - Official HF framework
   - ROCm Docker: `ghcr.io/huggingface/text-generation-inference:latest-rocm`
   - AWQ/GPTQ quantization
   - **Best for HF model ecosystem**

#### **Tier 3: Development Frameworks**

1. **llama.cpp** (Core library)
   - C++ API for custom tools
   - ROCm backend
   - Quantization (GGUF)
   - Server mode

2. **HuggingFace Optimum-AMD**
   - Native transformers
   - Zero code change from CUDA
   - Flash Attention 2
   - Direct model loading

3. **PyTorch with ROCm**
   - Full ML framework
   - Custom model development
   - Research workflows

---

## 📊 Framework Comparison

| Framework | Terminal | Local | ROCm | Features | Complexity | Best For |
|-----------|----------|-------|------|----------|------------|----------|
| **llama.vim** | ⭐⭐⭐⭐⭐ | ✅ | ✅ | ⭐⭐⭐ | ⭐ | Vim coding |
| **codecompanion.nvim** | ⭐⭐⭐⭐⭐ | ✅ | ✅ | ⭐⭐⭐⭐ | ⭐⭐ | Neovim power users |
| **Ollama** | ⭐⭐⭐⭐ | ✅ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐ | Simple API |
| **text-gen-webui** | ⭐⭐⭐ | ✅ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | Experimentation |
| **vLLM** | ⭐⭐ | ✅ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | Production serving |
| **HF TGI** | ⭐⭐ | ✅ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | HF models |
| **llama.cpp** | ⭐⭐⭐⭐ | ✅ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | Custom tools |

---

## 🛠️ Terminal Coding Assistants (Neovim)

### **Top Picks for Local LLM Support:**

#### **1. llama.vim** ⭐ **RECOMMENDED FOR PRIVACY**
- **Backend:** llama.cpp server
- **Local:** 100% offline
- **Features:**
  - Code/text completion
  - Runs on low-end hardware
  - No API keys
  - Private (prompts never leave machine)
- **Installation:** `Plug 'ggml-org/llama.vim'`

#### **2. llm.nvim**
- **Backend:** Multiple (Bard, HuggingFace, local models)
- **Privacy:** ✅ Local support
- **Features:**
  - Model flexibility
  - Cost-effective (free local)
  - Privacy-conscious

#### **3. codecompanion.nvim** ⭐ **RECOMMENDED FOR FLEXIBILITY**
- **Backend:** Ollama, Anthropic, OpenAI, Gemini, etc.
- **Local:** ✅ Via Ollama/llama.cpp
- **Features:**
  - Agent Client Protocol
  - LSP integration
  - Multi-provider support
  - Inline commands
  - Chat interface
- **Installation:**
  ```lua
  use 'olimorris/codecompanion.nvim'
  ```

#### **4. avante.nvim** (Cursor-like)
- **Backend:** Various (including local)
- **Features:**
  - LSP + Tree-sitter integration
  - Agentic mode (file ops, bash commands)
  - Cursor AI-like UX in Neovim
  - Complex task automation
- **For:** Advanced workflows

#### **5. Minuet**
- **Backend:** OpenAI, Gemini, Claude, Ollama, llama.cpp
- **Features:**
  - As-you-type completion
  - Multi-backend
  - Local support via Ollama/llama.cpp

### **Cloud-Based (Not Recommended for Privacy)**

- **ChatGPT.nvim** - Feature-complete but requires OpenAI
- **vim-ai** - Can use local proxy for Gemini/Claude
- **Copilot.vim** - GitHub Copilot (cloud-based)

---

## 💡 Recommendations for qalarc_OS

### **Phase 1: MVP (Minimal Viable Product)**

```nix
# modules/ai-ml/default.nix
environment.systemPackages = [
  # Core inference
  ollama              # Simple API, model management

  # Neovim plugins (via nixpkgs or manual)
  # llama.vim or codecompanion.nvim

  # Development
  python312Packages.torch  # PyTorch with ROCm
  python312Packages.transformers
];

services.ollama = {
  enable = true;
  acceleration = "rocm";
};
```

**Workflow:**
1. Ollama for quick testing
2. llama.vim in Neovim for coding
3. TMUX workspace with Qwen (existing qalarc-ai-workspace)

### **Phase 2: Enhanced (After testing)**

Add to MVP:
```nix
# Additional inference options
# text-generation-webui (via custom package or flake)
# vLLM (if production serving needed)

# Neovim plugins
# codecompanion.nvim (more features than llama.vim)
# avante.nvim (if agentic workflows desired)
```

### **Phase 3: Custom Terminal Interface**

Build your own:
- C++ or Python interface
- Direct llama.cpp integration
- Optimized for your workflow
- Custom keybindings, context management
- ROCm-specific optimizations

**Template:**
```cpp
// Custom terminal assistant
#include "llama.h"
#include "common.h"

int main() {
    // Load model
    llama_model* model = llama_load_model_from_file("model.gguf", params);

    // Initialize context with 96GB VRAM awareness
    llama_context* ctx = llama_new_context_with_model(model, ctx_params);

    // Inline terminal loop
    while (true) {
        // Read code context
        // Get user input
        // Generate inline suggestion
        // Display in terminal
    }
}
```

---

## 🎯 Model Recommendations

### **For Terminal Coding:**

1. **Qwen2.5-Coder** (3B, 7B, 14B, 32B)
   - Best for coding tasks
   - Good speed/quality balance
   - 32B fits in 96GB VRAM

2. **DeepSeek-Coder** (6.7B, 33B)
   - Excellent code quality
   - Fill-in-the-middle support
   - Good for completion

3. **CodeLlama** (7B, 13B, 34B)
   - Meta's code model
   - Well-tested
   - Good documentation

4. **Phind-CodeLlama** (34B)
   - Fine-tuned for coding
   - Strong problem-solving

### **For General Chat:**

1. **Llama 3.1** (8B, 70B, 405B)
   - 70B fits in 96GB VRAM
   - Excellent reasoning
   - Multi-lingual

2. **Mistral** (7B, 22B)
   - Fast inference
   - Good quality

3. **Qwen2.5** (0.5B to 72B)
   - Multilingual
   - Long context (128K tokens)

---

## 🔧 Integration Plan for qalarc_OS

### **Immediate Actions:**

1. **Keep Ollama** (already configured)
   - Easy model management
   - REST API for scripts

2. **Add llama.vim or codecompanion.nvim**
   - Terminal inline coding
   - Local inference
   - Vim/Neovim integration

3. **Configure Neovim with LSP**
   - Tree-sitter for syntax
   - LSP for type info
   - AI for generation

### **Optional Enhancements:**

1. **text-generation-webui**
   - Web UI for experimentation
   - Testing different models
   - Extension system

2. **vLLM**
   - If serving multiple users
   - Production deployments
   - High-performance needs

3. **Custom tools**
   - Your own terminal interface
   - Workflow-specific optimizations
   - Direct llama.cpp integration

---

## 📝 nixified.ai Assessment

**Why nixified.ai is limited:**

1. **Outdated packages** - Last updates 1-2 years ago
2. **Limited ROCm support** - CUDA-focused
3. **Minimal features** - Just ComfyUI, InvokeAI, textgen (deprecated)
4. **Poor documentation** - Sparse README
5. **No active development** - Stagnant project

**Better alternatives:**
- Build directly from nixpkgs
- Use official model frameworks
- Custom NixOS modules (what we're doing)

**Keep only as reference** - Don't depend on it.

---

## 🚀 Next Steps

1. ✅ **Research complete** - This document
2. ⏳ **USB installer** - Downloading (62% complete)
3. **Install qalarc_OS** - Deploy to GMKTEC
4. **Test Ollama + ROCm** - Verify 96GB VRAM
5. **Configure Neovim** - Add llama.vim or codecompanion.nvim
6. **Benchmark models** - Qwen2.5-Coder 32B, Llama 3.1 70B
7. **Build custom interface** - Terminal-optimized (optional)

---

## 📚 Resources

**Official Documentation:**
- AMD Ryzen AI: github.com/amd/ryzen-ai-documentation
- llama.cpp: github.com/ggerganov/llama.cpp
- HuggingFace Optimum-AMD: github.com/huggingface/optimum-amd
- text-generation-webui: github.com/oobabooga/text-generation-webui

**Neovim Plugins:**
- llama.vim: github.com/ggml-org/llama.vim
- codecompanion.nvim: github.com/olimorris/codecompanion.nvim
- avante.nvim: github.com/yetone/avante.nvim

**Models:**
- Qwen2.5-Coder: huggingface.co/Qwen
- DeepSeek-Coder: huggingface.co/deepseek-ai
- Llama 3.1: huggingface.co/meta-llama

---

**Last Updated:** 2025-11-15
**Status:** Research complete, ready for implementation
**Focus:** Terminal-first, local LLMs, privacy, performance
