# Qalarc OS Custom Packages

This directory contains custom Nix derivations for packages not available in nixpkgs.

## Packages

### claude-code
Official CLI for Claude AI coding assistant by Anthropic.
- Source: npm package `@anthropic-ai/claude-code`
- Version: 2.1.1
- License: Proprietary/Unfree

### opencode
AI coding assistant using local Ollama models.
- Source: GitHub `opencode-ai/opencode`
- Version: 0.0.55
- License: MIT

## Building

These packages are built automatically when you build the qalarc_OS configuration.

To build just these packages:
```bash
nix build .#nixosConfigurations.gmktec-01.config.system.build.toplevel
```

## Updating Package Hashes

When updating package versions, you'll need to update the SHA256 hashes:

### For claude-code (npm package):
```bash
# Get source hash
nix-prefetch-url https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-2.1.1.tgz

# Get npm dependencies hash (run build and use hash from error message)
nix build .#claude-code 2>&1 | grep "got:"
```

### For opencode (Go module):
```bash
# Get source hash
nix-prefetch-github opencode-ai opencode --rev v0.0.55

# Get vendor hash (run build and use hash from error message)
nix build .#opencode 2>&1 | grep "got:"
```

## Testing Packages

After updating hashes:

```bash
# Test claude-code
nix run .#claude-code -- --version

# Test opencode
nix run .#opencode -- --version
```

## Integration

These packages are integrated into qalarc_OS via:
1. **packages/default.nix** - Exports packages as an overlay
2. **flake.nix** - Applies the overlay to all configurations
3. **modules/ai-coding/default.nix** - Installs the packages

## Dependencies

### claude-code
- nodejs (provided by buildNpmPackage)
- No external dependencies

### opencode
- Go 1.24+ (for building)
- Ollama (runtime dependency, provided by ai-ml module)

## Notes

- **claude-code** requires an Anthropic API key to use (set via environment or config)
- **opencode** requires Ollama to be running locally
- Both packages are cross-platform but tested on x86_64-linux
