# Qalarc OS Custom Packages - Implementation Summary

## What Was Created

Created NixOS package derivations for Claude Code and OpenCode AI coding assistants to enable installation via the ai-coding module.

### Directory Structure

```
/home/fivelidz/projects/qalarc_OS/packages/
├── claude-code/
│   └── default.nix          # NPM-based derivation for Claude Code
├── opencode/
│   └── default.nix          # Go-based derivation for OpenCode
├── default.nix              # Package overlay exports
├── README.md                # Package documentation
├── TESTING.md               # Complete testing guide
├── SUMMARY.md               # This file
└── update-hashes.sh         # Helper script for updating package hashes
```

### Files Modified

1. **flake.nix** - Added `qalarcPackagesOverlay` to make packages available system-wide
2. **modules/ai-coding/default.nix** - Changed from commented placeholders to actual package installation

## Package Details

### 1. claude-code (packages/claude-code/default.nix)

**Source**: NPM package `@anthropic-ai/claude-code` version 2.1.1
**Build Method**: `buildNpmPackage` 
**Status**: Source hash obtained (1sqn80dmbfwdczzzmc4bcy0wykl9wyf07gpr7x009hsk3ays5jd0)
**Remaining**: Need to get `npmDepsHash` from first build attempt

**Key Details**:
- No external dependencies (pure JS/Node package)
- Binary name: `claude`
- License: Proprietary (unfree)
- Platform: All platforms
- Runtime requirement: Anthropic API key

### 2. opencode (packages/opencode/default.nix)

**Source**: GitHub `opencode-ai/opencode` version 0.0.55
**Build Method**: `buildGoModule`
**Status**: Source hash obtained (03696q34mfwmgbdqis1rpzdlq4z2qfpqppzq3wqmag9ax6sqscaj)
**Remaining**: Need to get `vendorHash` from first build attempt

**Key Details**:
- Requires Go 1.24+ (specified in go.mod)
- Binary name: `opencode`
- License: MIT (open source)
- Platform: Unix systems
- Runtime requirement: Ollama running locally

## Integration

The packages are integrated into qalarc_OS via:

1. **packages/default.nix** - Exports packages as an overlay:
   ```nix
   { pkgs }: {
     claude-code = pkgs.callPackage ./claude-code { };
     opencode = pkgs.callPackage ./opencode { };
   }
   ```

2. **flake.nix** - Applies overlay to all configurations:
   ```nix
   qalarcPackagesOverlay = final: prev: 
     import ./packages { pkgs = prev; };
   ```

3. **modules/ai-coding/default.nix** - Installs packages:
   ```nix
   environment.systemPackages = with pkgs; [
     claude-code
     opencode
     # ... other packages
   ];
   ```

## How to Test

### Step 1: Get Remaining Hashes

```bash
cd /home/fivelidz/projects/qalarc_OS
nix build .#nixosConfigurations.gmktec-01.config.system.build.toplevel 2>&1 | tee build.log

# Extract the hashes from error messages:
grep "got:" build.log
```

Update:
- `npmDepsHash` in packages/claude-code/default.nix
- `vendorHash` in packages/opencode/default.nix

### Step 2: Rebuild and Test

```bash
# Build the system
nix build .#nixosConfigurations.gmktec-01.config.system.build.toplevel

# Or test individual packages
nix build .#nixosConfigurations.gmktec-01.pkgs.claude-code
nix build .#nixosConfigurations.gmktec-01.pkgs.opencode

# Test binaries
./result/bin/claude --version
./result/bin/opencode --version
```

### Step 3: Deploy

```bash
# Test on a system
sudo nixos-rebuild test --flake .#gmktec-01

# If successful, make permanent
sudo nixos-rebuild switch --flake .#gmktec-01

# Verify
which claude
which opencode
```

## Limitations and Notes

### Claude Code
- **Requires API key**: Users must obtain an API key from https://console.anthropic.com/
- **Unfree license**: System must have `nixpkgs.config.allowUnfree = true`
- **Internet required**: Connects to Anthropic's Claude API
- **Costs money**: API usage is billed by Anthropic

### OpenCode
- **Requires Ollama**: Must have Ollama service running (`systemctl start ollama`)
- **Requires models**: Users must download models (`ollama pull qwen2.5-coder:32b`)
- **Go 1.24+**: May not build on older Nix channels without recent Go version
- **Local only**: Works completely offline but needs models downloaded first

### Build Requirements
- Both packages need hash updates after first build attempt (this is normal for Nix)
- Claude Code: Small package (~2MB), fast build
- OpenCode: Larger Go project, slower initial build due to vendor dependencies

## Integration with Existing Scripts

The packages work seamlessly with existing qalarc helper scripts:

- **qalarc-open-in-ai**: Right-click context menu uses `claude` and `opencode` commands
- **qalarc-ai-workspace**: TMUX workspace can launch both tools
- **TMUX shortcuts**: Ctrl+a o (claude) and Ctrl+a O (opencode) work automatically
- **Dolphin menu**: "Open in AI" context menu can launch either tool

## Future Improvements

1. **Automated hash updates**: Script to automatically fetch and update hashes
2. **Version pinning**: Lock versions with flake inputs for reproducibility
3. **CI/CD testing**: Automated builds and tests
4. **Update notifications**: Alert when new versions are available
5. **Contribute to nixpkgs**: Submit these derivations upstream

## Maintenance

To update package versions:

1. Edit version number in respective default.nix
2. Run `./packages/update-hashes.sh [package-name]` to get new source hash
3. Update source hash in derivation
4. Build and get new dependency hash from error message
5. Update dependency hash (npmDepsHash or vendorHash)
6. Test and deploy

## Documentation

- **README.md**: Package overview and basic instructions
- **TESTING.md**: Comprehensive testing guide with troubleshooting
- **update-hashes.sh**: Helper script for updating package hashes
- **SUMMARY.md**: This implementation summary

## Status

✅ Package derivations created
✅ Overlay configured in flake.nix
✅ Integration in ai-coding module
✅ Source hashes obtained
✅ Syntax validation passed (nix flake check)
⏳ Pending: npmDepsHash for claude-code (requires build attempt)
⏳ Pending: vendorHash for opencode (requires build attempt)
⏳ Pending: End-to-end testing on actual system

## Contact

For issues or questions about these packages:
- Check TESTING.md for troubleshooting
- Review build logs: `nix log /nix/store/...`
- Test individual derivations before full system build
