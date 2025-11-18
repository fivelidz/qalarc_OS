# qalarc_OS Drive Size Requirements

## Quick Reference

| Profile | Minimum | Recommended | With Models (70B) | Ideal |
|---------|---------|-------------|-------------------|-------|
| **Base System** | 32GB | 64GB | 128GB | 256GB |
| **AI Workstation** | 64GB | 128GB | 256GB | 512GB-2TB |
| **Gaming + AI** | 96GB | 256GB | 512GB | 1TB-2TB |

---

## Detailed Breakdown

### Base System Profile

**System Only** (no AI models):
- **Minimum**: 32GB
  - OS: ~15GB
  - Snapshots: ~5GB
  - Swap: 4GB
  - Free space: ~8GB
  - ⚠️ Very tight, not recommended

- **Recommended**: 64GB
  - OS: ~15GB
  - Snapshots: ~10GB
  - Swap: 8GB
  - Free space: ~31GB
  - ✅ Comfortable for development

**With Small Models** (1B-3B):
- **128GB**: Allows 3-5 small models
  - OS: ~15GB
  - Models: ~10-20GB
  - Snapshots: ~15GB
  - Free: ~70GB

---

### AI Workstation Profile

**System + Development Tools**:
- **Minimum**: 64GB
  - OS: ~25GB
  - Development: ~10GB
  - Snapshots: ~10GB
  - Containers: ~5GB
  - Free: ~14GB
  - ⚠️ No room for models

- **Recommended**: 128GB
  - OS: ~25GB
  - Development: ~10GB
  - Snapshots: ~15GB
  - Small models (3B-7B): ~15GB
  - Containers: ~10GB
  - Free: ~43GB
  - ✅ Good for development + small models

**With Medium Models** (7B-33B):
- **256GB**:
  - OS + Dev: ~35GB
  - Snapshots: ~20GB
  - Models: ~100GB (multiple 7B-13B models)
  - Containers: ~20GB
  - Free: ~80GB
  - ✅ Excellent for coding models

**With Large Models** (70B):
- **512GB**:
  - OS + Dev: ~35GB
  - Snapshots: ~30GB
  - Models: ~200GB (1-2 70B models + several smaller)
  - Containers: ~30GB
  - Free: ~217GB
  - ✅ Professional AI development

**Production AI Workstation**:
- **1TB-2TB**:
  - OS + Dev: ~40GB
  - Snapshots: ~50GB
  - Models: ~500GB-1.5TB (multiple 70B models, full library)
  - Containers: ~50GB
  - Datasets: ~100-500GB
  - Free: ~260GB-600GB
  - ✅ Full AI research/production

---

### Gaming + AI Profile

**System + Games** (no large AI models):
- **Minimum**: 96GB
  - OS + Gaming: ~40GB
  - Games: ~20GB (2-3 games)
  - Snapshots: ~15GB
  - Free: ~21GB
  - ⚠️ Very limited game library

- **Recommended**: 256GB
  - OS + Gaming: ~40GB
  - Games: ~100GB (10-15 games)
  - Snapshots: ~20GB
  - Small AI models: ~20GB
  - Free: ~76GB
  - ✅ Good gaming + small AI

**Gaming + Large AI Models**:
- **512GB**:
  - OS + Gaming: ~45GB
  - Games: ~150GB
  - Snapshots: ~30GB
  - AI models: ~150GB (70B + coding models)
  - Free: ~137GB
  - ✅ Full gaming + AI capability

**Ultimate Gaming + AI**:
- **1TB-2TB**:
  - OS + Gaming: ~50GB
  - Games: ~300-800GB (full library)
  - Snapshots: ~50GB
  - AI models: ~200-500GB
  - Free: ~400-900GB
  - ✅ Everything, no compromises

---

## Space Usage Details

### Operating System

| Component | Base | AI Workstation | Gaming + AI |
|-----------|------|----------------|-------------|
| NixOS Store | 10GB | 15GB | 20GB |
| Kernel & Drivers | 1GB | 2GB | 3GB |
| KDE Plasma | 2GB | 2GB | 2GB |
| Development Tools | 0GB | 5GB | 5GB |
| Gaming Software | 0GB | 0GB | 10GB |
| **Total** | **~13GB** | **~24GB** | **~40GB** |

### Snapshots (BTRFS)

**Retention Policy**:
- Hourly: 10 snapshots (~1-2GB each)
- Daily: 7 snapshots (~2-3GB each)
- Weekly: 4 snapshots (~3-5GB each)
- Monthly: 3 snapshots (~5-10GB each)
- Pre/Post updates: 10 snapshots (~5-10GB each)

**Estimated Total**:
- Minimal usage: 10-15GB
- Normal usage: 20-30GB
- Heavy usage: 40-60GB

### AI Models

**Model Sizes** (approximate):

| Model | Parameters | Quantization | Size |
|-------|-----------|--------------|------|
| Llama 3.2 1B | 1B | Full | 1.3GB |
| Llama 3.2 3B | 3B | Full | 2GB |
| Qwen 2.5 7B | 7B | Q8 | 7.5GB |
| Llama 3.1 8B | 8B | Q8 | 8.5GB |
| DeepSeek-Coder 6.7B | 6.7B | Q8 | 7GB |
| Mixtral 8x7B | 46.7B | Q4 | 26GB |
| Qwen 2.5 Coder 32B | 32B | Q8 | 18GB |
| DeepSeek-Coder 33B | 33B | Q8 | 19GB |
| Code Llama 34B | 34B | Q8 | 19GB |
| Llama 3.3 70B | 70B | Q8 | 40GB |
| Qwen 2.5 72B | 72B | Q8 | 41GB |
| Mistral 123B | 123B | Q4 | 63GB |

**Model Library Examples**:

**Minimal** (~10GB):
- 1x 3B model for testing

**Small** (~25GB):
- 2x 7B models (general + coding)
- 1x 3B model

**Medium** (~100GB):
- 1x 33B coding model
- 2x 7-8B models
- 2x 3B models

**Large** (~200GB):
- 1x 70B model
- 1x 33B coding model
- 3x 7-8B models
- 2x 3B models

**Complete** (~500GB+):
- 2x 70B+ models
- 2x 33B models
- 5x 7-8B models
- 3x 3B models

### Games (Gaming + AI profile only)

**Average Game Sizes**:
- Indie games: 2-10GB
- AA games: 20-50GB
- AAA games: 50-150GB
- Modern AAA: 100-200GB

**Typical Libraries**:
- **Light** (50GB): 10-15 indie/older games
- **Medium** (150GB): 5-10 modern games
- **Heavy** (300GB): 15-20 mixed games
- **Extensive** (500GB+): 20-30+ games

---

## Recommended Configurations

### Budget Setup (Testing/Learning)

**64GB Drive** + **AI Workstation**:
- Install base system
- Add 1-2 small models (3B-7B)
- Test and learn
- Upgrade later for large models

**Cost**: $15-30 (USB 3.0 64GB drive)

---

### Standard Setup (Development)

**256GB Drive** + **AI Workstation**:
- Full development environment
- 5-10 AI models (mix of 7B, 13B, 33B)
- Comfortable snapshot space
- Room to grow

**Cost**: $30-60 (USB 3.1/NVMe 256GB)

---

### Professional Setup (AI Work)

**512GB-1TB Drive** + **AI Workstation**:
- Complete AI development stack
- 10-15 models including 70B
- Extensive snapshots
- Datasets and experiments

**Cost**: $60-150 (NVMe/SSD 512GB-1TB)

---

### Ultimate Setup (Gaming + AI)

**2TB Drive** + **Gaming + AI**:
- Everything from AI Workstation
- Full game library (20-30 games)
- Extensive model collection
- No storage concerns

**Cost**: $120-250 (NVMe 2TB)

---

## Portable Installation Considerations

### USB 3.0/3.1 Drives

**Minimum**: 64GB (base system only)
**Recommended**: 128-256GB (system + models)
**Performance**: 50-80% of internal drive

**Pros**:
- Portable
- Cheap
- Widely compatible

**Cons**:
- Slower than SSD/NVMe
- Limited lifespan with heavy use

---

### External SSDs

**Minimum**: 128GB
**Recommended**: 256-512GB
**Performance**: 80-95% of internal drive

**Pros**:
- Fast (500-1000 MB/s)
- Durable
- Good for daily use

**Cons**:
- More expensive than USB drives

---

### External NVMe (USB-C/Thunderbolt)

**Minimum**: 256GB
**Recommended**: 512GB-2TB
**Performance**: 90-100% of internal drive

**Pros**:
- Very fast (1000-3000 MB/s)
- Best portable performance
- Professional quality

**Cons**:
- Most expensive
- Requires USB-C/Thunderbolt

---

## How to Check Available Space

### During Installation

The installer shows available disks:

```bash
Available disks:
nvme0n1  1.9TB  disk    # Internal NVMe
sda      256GB  disk    # External SSD
```

### After Installation

```bash
# Check disk usage
df -h /

# Detailed breakdown
du -sh /* 2>/dev/null | sort -h

# Check model storage
du -sh ~/Models/*

# Check snapshots
snapper list | wc -l
du -sh /.snapshots
```

---

## Recommendations by Use Case

### Just Testing qalarc_OS

**Drive**: 64GB USB 3.0
**Profile**: Base System
**Models**: 1-2 small (3B)
**Cost**: ~$20

---

### AI Development (Learning)

**Drive**: 128-256GB SSD
**Profile**: AI Workstation
**Models**: Multiple 7B-33B
**Cost**: ~$40-60

---

### Professional AI Development

**Drive**: 512GB-1TB NVMe
**Profile**: AI Workstation
**Models**: Full library (70B+)
**Cost**: ~$80-150

---

### Gaming + AI

**Drive**: 512GB-1TB SSD/NVMe
**Profile**: Gaming + AI
**Models**: Selected 70B + coding
**Games**: 10-15 games
**Cost**: ~$80-150

---

### Production AI Research

**Drive**: 2TB NVMe (internal recommended)
**Profile**: AI Workstation
**Models**: Complete library
**Datasets**: Extensive
**Cost**: ~$150-250

---

## Space Management Tips

### Keep System Clean

```bash
# Remove old snapshots
snapper delete <snapshot-number>

# Clean old Docker images
docker system prune -a

# Clean Nix store
nix-collect-garbage -d
sudo nix-collect-garbage -d
```

### Optimize Model Storage

```bash
# Use quantized models (Q4/Q5 instead of Q8)
ollama pull llama3.3:70b-q4  # 25GB instead of 40GB

# Remove unused models
ollama rm unused-model

# Check model sizes
ollama list
```

### Monitor Usage

```bash
# Check what's using space
ncdu /

# Watch disk usage in real-time
watch df -h /
```

---

**Last Updated**: 2025-11-17
**For**: qalarc_OS Phase 8
