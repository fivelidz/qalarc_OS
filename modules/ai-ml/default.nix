{ config, pkgs, lib, nixified-ai, ... }:

{
  # AI/ML software stack optimized for AMD Ryzen AI Max+ 395
  # Utilizes ROCm for GPU acceleration (96GB VRAM via UMA)

  # All AI/ML packages disabled for initial install
  # Install these manually after first boot with KDE working
  environment.systemPackages = with pkgs; [
    # Minimal ROCm tools only
    # rocmPackages.rocm-smi
    # rocmPackages.rocminfo
    # clinfo
  ];

  # Ollama service (LLM server) - DISABLED for initial install
  # Enable manually after first boot if needed
  # services.ollama = {
  #   enable = true;
  #   # Note: ROCm acceleration not available in nixpkgs 25.05 stable
  #   # Ollama will use CPU by default, or manually configure ROCm later
  #   # acceleration = "rocm";  # TODO: Enable when nixpkgs supports it
  # };

  # Environment variables for ROCm and AI workloads
  environment.variables = {
    # ROCm device selection
    ROCR_VISIBLE_DEVICES = "0";  # Use first GPU (Radeon 8060S)

    # HIP/ROCm configuration
    HSA_OVERRIDE_GFX_VERSION = "11.5.1";  # gfx1151 for Radeon 8060S

    # PyTorch ROCm backend
    PYTORCH_ROCM_ARCH = "gfx1151";
  };

  # GPU stats monitoring - DISABLED for initial install
  # Can be enabled after verifying ROCm works
  # systemd.services.gpu-stats-export = {
  #   description = "Export GPU statistics for AI assistant consumption";
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = pkgs.writeShellScript "export-gpu-stats" ''
  #       #!/bin/sh
  #       # Export GPU stats as JSON for CLI AI assistants
  #       ${pkgs.rocmPackages.rocm-smi}/bin/rocm-smi --showuse --showmeminfo --showtemp --json > /tmp/gpu-stats.json
  #       ${pkgs.jq}/bin/jq . /tmp/gpu-stats.json > /var/lib/qalarc/gpu-stats.json
  #     '';
  #   };
  # };

  # systemd.timers.gpu-stats-export = {
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnBootSec = "1min";
  #     OnUnitActiveSec = "5min";  # Update every 5 minutes
  #   };
  # };

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

  # Docker for containerized AI workloads
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Docker and GPU groups added via host config (user-specific)

  # CLI AI assistant interface notes:
  # - GPU stats: cat /var/lib/qalarc/gpu-stats.json
  # - Ollama API: curl http://localhost:11434/api/tags (list models)
  # - Running models: ollama list
  # - System state: cat /var/lib/qalarc/system-state.json
}
