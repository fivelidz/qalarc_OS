{ config, pkgs, lib, nixified-ai, ... }:

{
  # AI/ML software stack optimized for AMD Ryzen AI Max+ 395
  # Utilizes ROCm for GPU acceleration (96GB VRAM via UMA)

  environment.systemPackages = with pkgs; [
    # LLM inference engines
    ollama  # Easy-to-use LLM server with REST API
    # llama-cpp will be built with ROCm support via overlay

    # Python ML/AI environment
    python312
    python312Packages.pip
    python312Packages.pytorch-bin  # Will use ROCm via overlay
    python312Packages.transformers
    python312Packages.numpy
    python312Packages.pandas
    python312Packages.scikit-learn
    python312Packages.jupyter
    python312Packages.ipython

    # ROCm tools
    rocmPackages.rocm-smi  # AMD GPU monitoring (like nvidia-smi)
    rocmPackages.rocminfo  # ROCm system information
    clinfo  # OpenCL information

    # Model management tools
    huggingface-cli  # Download models from Hugging Face

    # Development tools for AI
    python312Packages.torch
    python312Packages.torchvision
    python312Packages.torchaudio
  ];

  # Ollama service (LLM server)
  services.ollama = {
    enable = true;
    # Note: ROCm acceleration not available in nixpkgs 25.05 stable
    # Ollama will use CPU by default, or manually configure ROCm later
    # acceleration = "rocm";  # TODO: Enable when nixpkgs supports it
  };

  # Environment variables for ROCm and AI workloads
  environment.variables = {
    # ROCm device selection
    ROCR_VISIBLE_DEVICES = "0";  # Use first GPU (Radeon 8060S)

    # HIP/ROCm configuration
    HSA_OVERRIDE_GFX_VERSION = "11.5.1";  # gfx1151 for Radeon 8060S

    # PyTorch ROCm backend
    PYTORCH_ROCM_ARCH = "gfx1151";

    # Ollama configuration
    OLLAMA_HOST = "0.0.0.0:11434";  # Allow network access
    # OLLAMA_MODELS path set by host config (varies by drive setup)

    # Python environment
    PYTHONPATH = "$PYTHONPATH:${pkgs.python312Packages.torch}/${pkgs.python312.sitePackages}";
  };

  # Systemd service for monitoring GPU usage (for AI assistant queries)
  systemd.services.gpu-stats-export = {
    description = "Export GPU statistics for AI assistant consumption";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "export-gpu-stats" ''
        #!/bin/sh
        # Export GPU stats as JSON for CLI AI assistants
        ${pkgs.rocmPackages.rocm-smi}/bin/rocm-smi --showuse --showmeminfo --showtemp --json > /tmp/gpu-stats.json
        ${pkgs.jq}/bin/jq . /tmp/gpu-stats.json > /var/lib/qalarc/gpu-stats.json
      '';
    };
  };

  systemd.timers.gpu-stats-export = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";  # Update every 5 minutes
    };
  };

  # Create directories for AI models and context
  # NOTE: /local-llms and /context are created by host-specific config
  # (either as mount points on dual-drive, or directories on single-drive)
  systemd.tmpfiles.rules = [
    "d /var/lib/qalarc 0755 root root -"  # System state for AI assistants
  ];

  # nixified.ai packages (if using the flake)
  # Note: nixified.ai currently has limited ROCm support
  # We'll primarily use native NixOS packages with ROCm
  # Uncomment if needed:
  # environment.systemPackages = [ nixified-ai.packages.${pkgs.system}.comfyui-amd ];

  # Docker for containerized AI workloads (optional)
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    # ROCm Docker configuration
    daemon.settings = {
      runtimes = {
        rocm = {
          path = "${pkgs.rocmPackages.clr}/bin/rocm-runtime";
        };
      };
    };
  };

  # Docker and GPU groups added via host config (user-specific)

  # CLI AI assistant interface notes:
  # - GPU stats: cat /var/lib/qalarc/gpu-stats.json
  # - Ollama API: curl http://localhost:11434/api/tags (list models)
  # - Running models: ollama list
  # - System state: cat /var/lib/qalarc/system-state.json
}
