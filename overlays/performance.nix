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

  # Use OpenBLAS with proper isILP64 attribute for numpy compatibility
  # (MKL lacks the isILP64 attribute that numpy expects)
  blas = super.blas.override { blasProvider = super.openblas; };
  lapack = super.lapack.override { lapackProvider = super.openblas; };

  # Optimize Ollama with ROCm support
  ollama = (optimizeForROCm super.ollama).overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ (with super; [
      rocmPackages.clr
      rocmPackages.rocm-smi
    ]);
  });

  # Enable hardware acceleration in FFmpeg
  # Note: ffmpeg-full already has most features enabled by default in nixpkgs
  # ffmpeg-full = super.ffmpeg-full;  # Use default (already full-featured)

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
