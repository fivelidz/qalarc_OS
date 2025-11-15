# Performance overlay for architecture-specific optimizations
# Trade binary cache for better performance on AMD Ryzen AI Max+ 395

self: super:

let
  # Helper to add optimization flags
  optimizeForNative = drv: drv.overrideAttrs (old: {
    NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -march=native -O3";
    NIX_CXXFLAGS_COMPILE = (old.NIX_CXXFLAGS_COMPILE or "") + " -march=native -O3";
  });

  # Helper for ROCm optimization
  optimizeForROCm = drv: drv.override {
    rocmSupport = true;
  };

in
{
  # Optimize llama.cpp for native architecture + ROCm
  llama-cpp = optimizeForNative (optimizeForROCm super.llama-cpp);

  # Optimize Python PyTorch for ROCm
  python312Packages = super.python312Packages // {
    torch = super.python312Packages.torch.override {
      # Use ROCm instead of CUDA
      rocmSupport = true;
      cudaSupport = false;
    };
  };

  # Use MKL-optimized BLAS/LAPACK (even on AMD, still faster than generic)
  blas = super.mkl;
  lapack = super.mkl;

  # Optimize Ollama with ROCm support
  ollama = (optimizeForROCm super.ollama).overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ (with super; [
      rocmPackages.clr
      rocmPackages.rocm-smi
    ]);
  });

  # Enable hardware acceleration in FFmpeg
  ffmpeg-full = super.ffmpeg-full.override {
    # Enable AMD-specific acceleration
    vaapiSupport = true;  # VA-API
    vulkanSupport = true; # Vulkan
  };

  # Note: Uncommenting the following will disable binary caches
  # and compile everything from source with -march=native.
  # This provides maximum performance but significantly increases build times.
  #
  # stdenv = super.stdenvAdapters.withCFlags [ "-march=native" "-O3" ] super.stdenv;
  #
  # Only enable this if you've benchmarked and determined the performance
  # gain is worth 10x+ longer build times for system packages.

  # Recommendations:
  # 1. Start with this overlay (optimizes critical AI packages only)
  # 2. Benchmark: llama.cpp inference, PyTorch matmul, system responsiveness
  # 3. If performance gap with CachyOS is >10%, consider full stdenv override
  # 4. Monitor build times: nix build --print-build-logs
}
