# qalarc_OS Storage Layout

## Hardware Configuration

**GMKTEC EVO-X2 AI Storage:**
- **2x M.2 2280 PCIe 4.0 NVMe slots** (supports up to 8TB each)
- **Slot 1 (nvme0n1)**: 2TB - System drive
- **Slot 2 (nvme1n1)**: 4TB - AI models + Context library (combined)

**Total Storage**: 6TB

---

## Drive Layout

### NVMe 0 (2TB) - System Drive `/dev/nvme0n1`

**Partitions:**
- `/dev/nvme0n1p1` - 512MB EFI boot partition
- `/dev/nvme0n1p2` - Remaining ~2TB LUKS encrypted BTRFS

**BTRFS Subvolumes:**
```
@ → / (root)
@home → /home
@nix → /nix
@snapshots → /.snapshots
@var-log → /var/log
```

**Purpose**: Operating system, user files, Nix store

**Snapshots**: Managed by Snapper (hourly/daily/weekly)

---

### NVMe 1 (4TB) - AI Models + Context `/dev/nvme1n1`

**Filesystem**: BTRFS with subvolumes

**Mount Points**:
- `/local-llms` - AI models subvolume (~3TB)
- `/context` - Context library subvolume (~1TB)

**Contents:**
```
/local-llms/
├── models/
│   ├── llama/          # Llama 3.1, 3.2, 4
│   ├── qwen/           # Qwen 2.5 Coder, Qwen3
│   ├── deepseek/       # DeepSeek Coder, DeepSeek V3
│   ├── mistral/        # Mistral, Mixtral
│   └── specialized/    # Code models, vision models
├── quantized/
│   ├── gguf/          # GGUF quantized models
│   ├── awq/           # AWQ quantized
│   └── gptq/          # GPTQ quantized
├── embeddings/
│   └── sentence-transformers/
└── cache/
    └── huggingface/   # HF cache directory
```

**Estimated Capacity (3TB for models):**
- ~40-50 models (70B-405B range with quantization)
- Full precision 70B: ~140GB each
- Quantized 70B: ~40-70GB each
- 3TB = ~60 quantized 70B models OR ~21 full precision 70B models

**Compression**: Minimal (zstd:1) - AI models already compressed

**Snapshots**: Optional, mainly for rollback after model updates

**Contents:**
```
/context/
├── nixos/                         # NixOS documentation & examples
│   ├── docs/
│   │   ├── nixos-manual/         # Official manual
│   │   ├── home-manager/         # Home Manager docs
│   │   ├── nixos-wiki/           # Community wiki
│   │   └── nix-pills/            # Nix Pills tutorial
│   ├── packages/
│   │   ├── nixpkgs-cache.json   # Package search cache
│   │   └── option-docs/          # All NixOS options
│   ├── examples/
│   │   ├── starter-configs/     # Beginner templates
│   │   ├── expert-dotfiles/     # Advanced configurations
│   │   └── specialized/         # Gaming, AI, servers
│   ├── discourse/               # NixOS Discourse archive
│   └── github-issues/          # Issue tracker mirror
│
├── programming/                  # Programming documentation
│   ├── languages/
│   │   ├── rust/                # Rust stdlib + docs
│   │   ├── python/              # Python docs
│   │   ├── cpp/                 # C++ references
│   │   └── nix/                 # Nix language guide
│   ├── frameworks/
│   │   ├── pytorch/             # PyTorch docs
│   │   ├── tensorflow/          # TensorFlow docs
│   │   └── rocm/                # ROCm documentation
│   └── algorithms/
│       └── leetcode-solutions/  # Coding problems
│
├── ai-ml/                        # AI/ML documentation
│   ├── papers/
│   │   ├── arxiv-mirror/       # Research papers
│   │   └── summaries/          # Paper summaries
│   ├── tutorials/
│   │   ├── huggingface/        # HF guides
│   │   └── fast-ai/            # Fast.ai courses
│   ├── model-cards/            # Model documentation
│   └── datasets/
│       └── metadata/           # Dataset descriptions
│
├── knowledge/                    # General knowledge base
│   ├── wikipedia/
│   │   ├── offline-dump/       # Wikipedia XML dump (~100GB compressed)
│   │   └── index/              # Search index
│   ├── books/
│   │   ├── technical/          # Programming books (legal copies)
│   │   ├── ai-ml/              # AI/ML textbooks
│   │   └── reference/          # Manuals, RFCs
│   ├── articles/
│   │   └── tech-blogs/         # Saved blog posts
│   └── stack-exchange/
│       ├── stackoverflow/      # SO dump
│       └── unix-stackexchange/ # Unix SE
│
├── datasets/                     # Training/fine-tuning data
│   ├── code/
│   │   ├── the-stack/          # Code dataset
│   │   └── github-repos/       # Selected repos
│   ├── text/
│   │   ├── gutenberg/          # Project Gutenberg
│   │   └── common-crawl/       # Web text samples
│   └── specialized/
│       └── nix-configurations/ # NixOS configs dataset
│
├── torrents/                     # Torrent distribution
│   ├── active/                 # Currently seeding
│   ├── completed/              # Downloaded content
│   └── metadata/               # .torrent files
│
└── rag-indexes/                  # Vector databases
    ├── nixos-index/            # NixOS semantic search
    ├── code-index/             # Code search
    └── wiki-index/             # Wikipedia search
```

**Estimated Capacity (1TB for context):**
- NixOS docs + examples: ~50GB
- Wikipedia offline (compressed subset): ~50GB
- Programming docs: ~100GB
- Research papers (curated): ~200GB
- Stack Exchange dumps (selected): ~50GB
- Code datasets (samples): ~300GB
- RAG indexes: ~50GB
- **Remaining**: ~200GB for expansion

**Compression**: Medium (zstd:3) - Good balance for text

**Snapshots**: Daily snapshots of index updates

**Note**: This is a curated 1TB subset. Full datasets can be stored on external drives and selectively copied as needed.

---

## Mount Configuration (hardware-configuration.nix)

```nix
{
  # System drive (existing)
  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd:3" "noatime" ];
  };

  # ... other system subvolumes ...

  # AI Models + Context drive (4TB, shared)
  fileSystems."/local-llms" = {
    device = "/dev/disk/by-uuid/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX";
    fsType = "btrfs";
    options = [ "subvol=@local-llms" "compress=zstd:1" "noatime" ];
  };

  fileSystems."/context" = {
    device = "/dev/disk/by-uuid/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX";  # Same UUID as /local-llms
    fsType = "btrfs";
    options = [ "subvol=@context" "compress=zstd:3" "noatime" ];
  };
}
```

---

## Installation Steps for Additional Drives

### During NixOS Installation:

```bash
# Format second drive
mkfs.btrfs -L "AI-DATA" /dev/nvme1n1

# Mount and create subvolumes
mount /dev/nvme1n1 /mnt/local-llms
cd /mnt/local-llms
btrfs subvolume create @local-llms
btrfs subvolume create @context
cd /
umount /mnt/local-llms

# Mount both subvolumes
mount -o subvol=@local-llms,compress=zstd:1,noatime /dev/nvme1n1 /mnt/local-llms
mount -o subvol=@context,compress=zstd:3,noatime /dev/nvme1n1 /mnt/context

# Get UUID for configuration
lsblk -o NAME,UUID,SIZE,FSTYPE
```

### After Installation:

UUIDs will be automatically detected by `nixos-generate-config` and added to `hardware-configuration.nix`.

---

## Backup Strategy

**System Drive (2TB):**
- Snapper automatic snapshots
- GRUB boot menu integration
- Keep 24 hourly, 7 daily, 4 weekly, 6 monthly

**AI Models (4TB):**
- Manual snapshots before major updates
- Models re-downloadable from HuggingFace
- Low priority for backup

**Context Library (4TB):**
- Daily snapshots of indexes
- Most content re-downloadable
- Torrent metadata backed up to system drive
- High priority: Custom RAG indexes, curated collections

---

## Torrent Seeding Strategy

**Upload Context Library via Torrents:**

1. Create torrents for major collections:
   - NixOS documentation bundle
   - Wikipedia offline dump
   - Programming docs collection
   - AI/ML papers archive

2. Seed from `/context/torrents/active/`

3. Share .torrent files via:
   - GitHub repository (qalarc-context-library)
   - Personal website
   - NixOS community forums

4. Other qalarc_OS users can download via:
   ```bash
   qbittorrent /path/to/nixos-docs.torrent
   # Downloads to /context/torrents/completed/
   ```

**Benefits:**
- Offline-first AI development
- Fast local context retrieval
- Community-shared knowledge bases
- Bandwidth-efficient distribution

---

## Context Library Population

**Automated downloads:**
```bash
# Download NixOS documentation
qalarc-nixos-update-context

# Download Wikipedia offline
qalarc-download-wikipedia

# Download programming docs
qalarc-download-programming-docs

# Create torrent bundle
qalarc-create-context-torrent
```

**Manual curation:**
- Add research papers to `/context/ai-ml/papers/`
- Clone important GitHub repos to `/context/datasets/code/`
- Save blog posts to `/context/knowledge/articles/`

---

## Usage Examples

**AI Models:**
```bash
# Download model
cd /local-llms/models/qwen
wget https://huggingface.co/...

# Use with Ollama
OLLAMA_MODELS=/local-llms/models ollama serve

# Use with text-generation-webui
python server.py --model-dir /local-llms/models
```

**Context Library:**
```bash
# Search NixOS docs
qalarc-nixos-ai ask "How do I configure nvidia drivers?"

# Search Wikipedia offline
qalarc-wiki-search "Ryzen AI architecture"

# Search code examples
qalarc-code-search "BTRFS snapshot script bash"
```

---

## Disk Space Monitoring

**Helper commands:**
```bash
# Check all drives
df -h | grep -E 'nvme|Filesystem'

# Detailed BTRFS usage
sudo btrfs filesystem usage /
sudo btrfs filesystem usage /local-llms
sudo btrfs filesystem usage /context

# Model storage
du -sh /local-llms/models/*

# Context library size
du -sh /context/*
```

---

## Future Enhancements

1. **Automated context updates** via systemd timers
2. **RAG vector database** for semantic search
3. **Distributed seeding** across multiple qalarc_OS instances
4. **Context deduplication** using BTRFS features
5. **Smart caching** of frequently-accessed docs in RAM

---

**Last Updated**: 2025-11-15
**For**: qalarc_OS deployment on GMKTEC EVO-X2 AI (3x NVMe configuration)
