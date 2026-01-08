# Quick Start: Finalizing Package Hashes

The package derivations are 95% complete. You just need to get two hash values that can only be obtained by attempting a build.

## TL;DR - Run This

```bash
cd /home/fivelidz/projects/qalarc_OS

# Attempt build (will fail with correct hashes)
nix --extra-experimental-features 'nix-command flakes' build \
  .#nixosConfigurations.gmktec-01.config.system.build.toplevel 2>&1 | tee build.log

# Find the hashes in the error output
grep "got:" build.log
```

You'll see two hash errors like:
```
specified: sha256-AAAAAAA...
     got:    sha256-actual-hash-here-1234567890abcdef...
```

## Update the Hashes

### For claude-code
1. Open: `packages/claude-code/default.nix`
2. Find line with: `npmDepsHash = "sha256-AAAA..."`
3. Replace with the hash from the error (the "got:" line)

### For opencode
1. Open: `packages/opencode/default.nix`
2. Find line with: `vendorHash = "sha256-AAAA..."`
3. Replace with the hash from the error (the "got:" line)

## Rebuild

```bash
# Try again
nix --extra-experimental-features 'nix-command flakes' build \
  .#nixosConfigurations.gmktec-01.config.system.build.toplevel

# Should succeed this time!
```

## Test

```bash
# Deploy to system
sudo nixos-rebuild switch --flake .#gmktec-01

# Test the commands
claude --version
opencode --version
```

## If You Get Stuck

See `packages/TESTING.md` for detailed troubleshooting.

## What Was Created

- ✅ `packages/claude-code/` - Claude Code NPM package derivation
- ✅ `packages/opencode/` - OpenCode Go module derivation  
- ✅ `packages/default.nix` - Package overlay
- ✅ `flake.nix` - Updated with overlay
- ✅ `modules/ai-coding/default.nix` - Installing the packages
- ✅ Source hashes obtained
- ⏳ Need npmDepsHash for claude-code (you'll get this from build error)
- ⏳ Need vendorHash for opencode (you'll get this from build error)

That's it! The hard part is done. Just need those two hash values.
