{ config, pkgs, lib, ... }:

{
  # AI/ML software stack optimized for AMD Ryzen AI Max+ 395
  # Utilizes ROCm for GPU acceleration (96GB VRAM via UMA)

  environment.systemPackages = with pkgs; [
    # LLM inference engines
    # Note: ollama is installed via services.ollama below

    # ROCm tools - essential for GPU monitoring and debugging
    rocmPackages.rocm-smi    # AMD GPU monitoring (like nvidia-smi)
    rocmPackages.rocminfo    # ROCm system information
    clinfo                   # OpenCL information

    # Python ML/AI environment - core packages
    python312
    python312Packages.pip
    python312Packages.numpy
    python312Packages.pandas
    python312Packages.scikit-learn
    python312Packages.jupyter
    python312Packages.ipython

    # Hugging Face tools
    python312Packages.huggingface-hub

    # JSON processing for AI assistant data exchange
    jq
  ];

  # Ollama service (LLM server) with ROCm acceleration
  # NOTE: The 'acceleration' option is deprecated in NixOS 25.05+
  # Use the ollama-rocm package directly instead
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;  # Use ROCm-enabled Ollama
    # Models stored in /var/lib/ollama by default
    # Can customize with: home = "/local-llms/ollama";
  };

  # Environment variables for ROCm and AI workloads
  environment.variables = {
    # ROCm device selection
    ROCR_VISIBLE_DEVICES = "0";  # Use first GPU (Radeon 8060S)

    # HIP/ROCm configuration for Strix Halo (gfx1151)
    HSA_OVERRIDE_GFX_VERSION = "11.5.1";  # gfx1151 for Radeon 8060S

    # PyTorch ROCm backend
    PYTORCH_ROCM_ARCH = "gfx1151";

    # Ollama configuration
    OLLAMA_HOST = "0.0.0.0:11434";  # Allow network access
  };

  # GPU stats monitoring - exports data for AI assistants to consume
  systemd.services.gpu-stats-export = {
    description = "Export GPU statistics for AI assistant consumption";
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "export-gpu-stats" ''
        #!/bin/sh
        # Export GPU stats as JSON for CLI AI assistants
        mkdir -p /var/lib/qalarc
        if command -v rocm-smi >/dev/null 2>&1; then
          ${pkgs.rocmPackages.rocm-smi}/bin/rocm-smi --showuse --showmeminfo vram --showtemp --json 2>/dev/null > /var/lib/qalarc/gpu-stats.json || echo '{"error": "rocm-smi failed"}' > /var/lib/qalarc/gpu-stats.json
        else
          echo '{"error": "rocm-smi not available"}' > /var/lib/qalarc/gpu-stats.json
        fi
      '';
    };
  };

  systemd.timers.gpu-stats-export = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";  # Update every 5 minutes
    };
  };

  # Create directories for AI models and system state
  # NOTE: /local-llms and /context mount points are created by host-specific config
  # This creates the state directory for AI assistant data exchange
  systemd.tmpfiles.rules = [
    "d /var/lib/qalarc 0755 root root -"  # System state for AI assistants
  ];

  # Docker for containerized AI workloads (ComfyUI, etc.)
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    # Enable GPU passthrough for Docker containers
    daemon.settings = {
      "default-runtime" = "runc";
    };
  };

  # CLI AI assistant interface notes:
  # - GPU stats: cat /var/lib/qalarc/gpu-stats.json
  # - Ollama API: curl http://localhost:11434/api/tags (list models)
  # - Running models: ollama list
  # - Pull model: ollama pull llama3.3:70b
  # - ROCm info: rocminfo
  # - GPU monitor: rocm-smi
}
