# Testing Qalarc OS Custom Packages

This guide explains how to test and finalize the custom package derivations.

## Step 1: Update Remaining Hashes

The derivations need two types of hashes that can only be obtained by attempting a build:

### For claude-code: npmDepsHash

```bash
cd /home/fivelidz/projects/qalarc_OS

# Attempt to build - it will fail with the correct hash
nix build .#nixosConfigurations.gmktec-01.config.system.build.toplevel 2>&1 | tee build.log

# Look for the npmDepsHash error:
grep "got:" build.log | grep claude-code
```

Update the `npmDepsHash` in `packages/claude-code/default.nix` with the hash from the error message.

### For opencode: vendorHash

```bash
# Same process for opencode
grep "got:" build.log | grep opencode
```

Update the `vendorHash` in `packages/opencode/default.nix` with the hash from the error message.

## Step 2: Rebuild After Hash Updates

After updating both hashes:

```bash
# Try building again
nix build .#nixosConfigurations.gmktec-01.config.system.build.toplevel

# Or test individual packages
nix build .#nixosConfigurations.gmktec-01.pkgs.claude-code
nix build .#nixosConfigurations.gmktec-01.pkgs.opencode
```

## Step 3: Test Package Functionality

### Test claude-code

```bash
# Run from the built package
./result/bin/claude --version

# Or if installed on the system
claude --version
claude --help
```

**Note**: Claude Code requires an Anthropic API key. Set it via:
```bash
export ANTHROPIC_API_KEY="your-key-here"
# OR
claude  # It will prompt for API key on first run
```

### Test opencode

```bash
# Ensure Ollama is running
systemctl status ollama

# Test opencode
./result/bin/opencode --version
opencode --help

# Try running it (will need Ollama with models installed)
opencode
```

## Step 4: Integration Testing

Test the full integration in the ai-coding module:

```bash
# Check that packages are available in the system
nix-shell -p qalarc_OS.claude-code qalarc_OS.opencode

# In the shell:
which claude
which opencode
claude --version
opencode --version
```

## Step 5: Test Scripts and Integration

Test the qalarc helper scripts that use these tools:

```bash
# Test the AI launcher
qalarc-open-in-ai ~/test-project

# Test TMUX shortcuts (if in a TMUX session)
# Ctrl+a then o should launch claude
# Ctrl+a then O should launch opencode

# Test AI workspace
qalarc-ai-workspace
```

## Common Issues and Solutions

### Issue: "unfree package" error

Solution: Add to configuration.nix:
```nix
nixpkgs.config.allowUnfree = true;
```

### Issue: Go version too old for opencode

Solution: The derivation should handle this, but if needed:
```nix
# In packages/opencode/default.nix, ensure Go 1.24+
buildGoModule.override { go = pkgs.go_1_24; }
```

### Issue: Claude Code requires API key

Solution: This is expected behavior. Users need to:
1. Get API key from https://console.anthropic.com/
2. Set `ANTHROPIC_API_KEY` environment variable
3. Or let Claude Code prompt on first run

### Issue: OpenCode can't find Ollama

Solution: Ensure Ollama is running:
```bash
systemctl status ollama
systemctl start ollama
ollama list  # Check installed models
```

## Validation Checklist

- [ ] claude-code builds successfully
- [ ] opencode builds successfully
- [ ] claude-code binary is in PATH
- [ ] opencode binary is in PATH
- [ ] claude --version works
- [ ] opencode --version works
- [ ] qalarc-open-in-ai script runs
- [ ] TMUX shortcuts work (Ctrl+a o/O)
- [ ] Right-click "Open in AI" menu appears in Dolphin

## Deployment

Once all tests pass:

```bash
# Apply to a test system first
sudo nixos-rebuild test --flake .#gmktec-01

# If everything works, make it permanent
sudo nixos-rebuild switch --flake .#gmktec-01

# Verify installation
which claude
which opencode
claude --version
opencode --version
```

## Troubleshooting Build Errors

### Error: "hash mismatch"
- The hash in the derivation doesn't match the actual file
- Get the correct hash using nix-prefetch-url or from error message
- Update the derivation

### Error: "attribute 'claude-code' missing"
- The overlay might not be applied correctly
- Check flake.nix has qalarcPackagesOverlay in nixpkgs.overlays
- Rebuild with: nix flake update

### Error: "builder for ... failed"
- Check the full build log: nix log /nix/store/...
- Common causes:
  - Missing dependencies
  - Build script errors
  - Network issues during build

## Next Steps

After successful testing:

1. Update version numbers in derivations as new releases come out
2. Consider contributing these derivations to nixpkgs
3. Add automated tests in CI/CD
4. Document any special configuration needed for users
