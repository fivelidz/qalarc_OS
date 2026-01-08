# Ollama AI Models Guide

**Everything you need to know about downloading, managing, and using local AI models on Qalarc AI-OS.**

This guide helps you choose the right models for your needs and manage your storage effectively.

---

## Table of Contents

1. [What is Ollama?](#what-is-ollama)
2. [How AI Models Work](#how-ai-models-work)
3. [Downloading Models](#downloading-models)
4. [Recommended Models by Task](#recommended-models-by-task)
5. [Model Comparison Table](#model-comparison-table)
6. [How to Switch Models](#how-to-switch-models)
7. [Storage Management](#storage-management)
8. [Performance Tips](#performance-tips)
9. [Troubleshooting](#troubleshooting)

---

## What is Ollama?

**Ollama** is a tool that lets you run large AI models (like ChatGPT or Claude) on your own computer.

**Think of it as:**
- A "Netflix for AI models" - download and run models locally
- An AI model manager - handles downloads, updates, and running models
- A local AI server - provides an API for other apps (like OpenCode)

**Why use Ollama?**
- ✅ **Privacy**: Your conversations never leave your computer
- ✅ **Free**: No API costs or subscriptions
- ✅ **Offline**: Works without internet (after downloading models)
- ✅ **Fast**: Uses your 96GB of VRAM for maximum performance
- ✅ **Flexible**: Run different models for different tasks

---

## How AI Models Work

### Understanding Model Sizes

AI models are measured in **parameters** (like "7B" or "70B"):

- **7B = 7 billion parameters** (Small model)
- **32B = 32 billion parameters** (Medium model)
- **70B = 70 billion parameters** (Large model)

**More parameters generally means:**
- ✅ Better quality responses
- ✅ Better reasoning ability
- ✅ More knowledge
- ❌ Larger download size
- ❌ More RAM/VRAM needed
- ❌ Slower response time

### Model Families

Models come in "families" with different versions:

**Example: Llama Family**
- `llama3.3:8b` - Small, fast (4GB)
- `llama3.3:70b` - Large, powerful (38GB)
- `llama3.3:405b` - Huge, most capable (220GB - too big for most systems!)

**Specializations:**
- **Regular models**: General conversation and tasks
- **Coder models**: Optimized for writing code
- **Instruct models**: Better at following instructions
- **Chat models**: Better at conversations

---

## Downloading Models

### Basic Download Command

```bash
ollama pull <model-name>
```

**Example:**
```bash
ollama pull qwen2.5-coder:32b
```

This downloads the model to `/local-llms/` on your system.

### Step-by-Step: Your First Model

**1. Open a terminal:**
- Click Ghostty icon in taskbar, or
- Press `Super + Return`

**2. Check what's already installed:**
```bash
ollama list
```

**3. Download a recommended coding model:**
```bash
ollama pull qwen2.5-coder:32b
```

**4. Wait for download:**
- Shows progress bar
- Takes 5-30 minutes depending on model size and internet speed
- You can use your computer normally while downloading

[SCREENSHOT: Terminal showing ollama pull progress]

**5. Verify installation:**
```bash
ollama list
```

You should see your new model in the list!

**6. Test the model:**
```bash
ollama run qwen2.5-coder:32b
```

Type a message and press Enter to chat!

**To exit chat:**
Type `/bye` or press `Ctrl+D`

---

## Recommended Models by Task

### For Coding (Most Important)

#### 🥇 **qwen2.5-coder:32b** (Recommended)
- **Size**: 18GB
- **RAM needed**: 24GB+
- **Best for**: Writing code, explaining code, debugging
- **Quality**: Excellent
- **Speed**: Fast on your hardware

**Download:**
```bash
ollama pull qwen2.5-coder:32b
```

**Why this model?**
- Best coding model for local use
- Great balance of quality and speed
- Works perfectly with your 96GB VRAM
- Trained on massive code datasets

---

#### 🥈 **deepseek-coder:33b**
- **Size**: 20GB
- **RAM needed**: 26GB+
- **Best for**: Code generation, algorithms
- **Quality**: Excellent
- **Speed**: Fast

**Download:**
```bash
ollama pull deepseek-coder:33b
```

**Alternative to Qwen Coder, try both and pick your favorite!**

---

#### 🥉 **codellama:34b**
- **Size**: 20GB
- **RAM needed**: 26GB+
- **Best for**: Python, C++, general coding
- **Quality**: Very good
- **Speed**: Fast

**Download:**
```bash
ollama pull codellama:34b
```

**Made by Meta (Facebook), very reliable.**

---

#### ⚡ **qwen2.5-coder:7b** (Budget/Fast Option)
- **Size**: 4GB
- **RAM needed**: 8GB+
- **Best for**: Quick questions, learning, older hardware
- **Quality**: Good
- **Speed**: Very fast

**Download:**
```bash
ollama pull qwen2.5-coder:7b
```

**Perfect if you want fast responses or have limited RAM.**

---

### For General Chat & Questions

#### 🥇 **llama3.3:70b** (Recommended)
- **Size**: 38GB
- **RAM needed**: 48GB+
- **Best for**: Conversations, explanations, writing
- **Quality**: Excellent (close to ChatGPT 4)
- **Speed**: Medium

**Download:**
```bash
ollama pull llama3.3:70b
```

**Best general-purpose model for your hardware.**

---

#### 🥈 **mistral:7b**
- **Size**: 4GB
- **RAM needed**: 8GB+
- **Best for**: Quick questions, general chat
- **Quality**: Very good
- **Speed**: Very fast

**Download:**
```bash
ollama pull mistral:7b
```

**Great lightweight option for everyday use.**

---

#### ⚡ **phi3:14b**
- **Size**: 8GB
- **RAM needed**: 12GB+
- **Best for**: Research, technical writing
- **Quality**: Good
- **Speed**: Fast

**Download:**
```bash
ollama pull phi3:14b
```

**Made by Microsoft, efficient and smart.**

---

### For Specialized Tasks

#### 📝 **Writing & Content**: llama3.3:70b
Best for blog posts, emails, creative writing

#### 🧮 **Math & Logic**: qwen2.5-coder:32b
Great at reasoning through complex problems

#### 🌍 **Multilingual**: qwen2.5:32b
Excellent at non-English languages

#### 🔍 **Research & Analysis**: llama3.3:70b
Strong at synthesizing information

---

## Model Comparison Table

| Model Name | Size | RAM Needed | Best For | Quality | Speed |
|------------|------|------------|----------|---------|-------|
| **qwen2.5-coder:32b** ⭐ | 18GB | 24GB+ | Coding | ⭐⭐⭐⭐⭐ | ⚡⚡⚡⚡ |
| **llama3.3:70b** ⭐ | 38GB | 48GB+ | General | ⭐⭐⭐⭐⭐ | ⚡⚡⚡ |
| **mistral:7b** | 4GB | 8GB+ | Quick tasks | ⭐⭐⭐⭐ | ⚡⚡⚡⚡⚡ |
| **deepseek-coder:33b** | 20GB | 26GB+ | Coding | ⭐⭐⭐⭐⭐ | ⚡⚡⚡⚡ |
| **codellama:34b** | 20GB | 26GB+ | Python/C++ | ⭐⭐⭐⭐ | ⚡⚡⚡⚡ |
| **phi3:14b** | 8GB | 12GB+ | Research | ⭐⭐⭐⭐ | ⚡⚡⚡⚡ |
| **qwen2.5-coder:7b** | 4GB | 8GB+ | Learning | ⭐⭐⭐ | ⚡⚡⚡⚡⚡ |
| **llama3.1:8b** | 4GB | 8GB+ | Chat | ⭐⭐⭐ | ⚡⚡⚡⚡⚡ |

**Legend:**
- ⭐ = Quality rating (more stars = better)
- ⚡ = Speed rating (more lightning = faster)

---

## How to Switch Models

### In OpenCode

**Method 1: Via right-click menu**
1. Right-click folder → "Open in AI"
2. Choose OpenCode
3. Select your desired model from dropdown

**Method 2: Via environment variable**
```bash
export OLLAMA_MODEL=qwen2.5-coder:32b
opencode
```

**Method 3: In running OpenCode**
Type in the chat:
```
/model qwen2.5-coder:32b
```

---

### In Terminal (Direct Ollama)

**Start a specific model:**
```bash
ollama run mistral:7b
```

**Switch models:**
Exit current chat (`/bye` or `Ctrl+D`) and start a new one:
```bash
ollama run llama3.3:70b
```

---

### Setting a Default Model

**Edit your shell configuration:**

For Fish shell (Qalarc default):
```bash
echo "set -x OLLAMA_MODEL qwen2.5-coder:32b" >> ~/.config/fish/config.fish
```

For Bash:
```bash
echo "export OLLAMA_MODEL=qwen2.5-coder:32b" >> ~/.bashrc
```

**Reload your terminal** or run:
```bash
source ~/.config/fish/config.fish
```

---

## Storage Management

### Check Storage Usage

**See all downloaded models:**
```bash
ollama list
```

Output shows:
- Model name
- Size on disk
- Modified date

**Check available space:**
```bash
df -h /local-llms
```

Shows:
- Total space
- Used space
- Available space

[SCREENSHOT: Terminal showing df output]

---

### Deleting Models

**Remove a model you don't use:**
```bash
ollama rm <model-name>
```

**Example:**
```bash
ollama rm mistral:7b
```

**Delete multiple models:**
```bash
ollama rm model1:tag model2:tag model3:tag
```

**⚠️ Warning:** This permanently deletes the model! You'll need to re-download it if you want it back.

---

### Storage Recommendations

**Your system has:**
- 2TB system drive (OS and apps)
- 4TB AI/context drive (AI models and data)

**Recommended setup for 128GB RAM systems:**

**Essential models (download first):**
- qwen2.5-coder:32b (18GB) - Primary coding model
- mistral:7b (4GB) - Fast general use
- **Total: ~22GB**

**Nice to have (if space permits):**
- llama3.3:70b (38GB) - Best general model
- deepseek-coder:33b (20GB) - Alternative coder
- **Total: ~80GB**

**Power user collection:**
- All of the above
- codellama:34b (20GB)
- phi3:14b (8GB)
- qwen2.5:32b (18GB) - Multilingual
- **Total: ~126GB**

**You can comfortably store 100-150GB of models!**

---

### Cleanup Strategy

**Keep models you use daily:**
- Primary coding model (qwen2.5-coder:32b)
- One fast general model (mistral:7b)

**Remove models you rarely use:**
```bash
# See last used date
ollama list

# Remove old models
ollama rm old-model:tag
```

**Download on demand:**
- Large models for specific projects
- Delete when done
- Re-download when needed (faster than keeping everything)

---

## Performance Tips Based on RAM

### Your System: 128GB RAM / 96GB VRAM

**You can run:**
- ✅ Multiple 70B models simultaneously
- ✅ 100+ GB total models loaded
- ✅ Large models with plenty of room

**Optimal configuration:**
1. Keep 2-3 frequently-used models
2. Load one large model at a time
3. System will auto-manage memory

---

### Performance Optimization

**For fastest responses:**
1. **Use smaller models**: mistral:7b, qwen2.5-coder:7b
2. **Close unnecessary apps**: Free up RAM
3. **Use GPU acceleration**: Already enabled on Qalarc OS

**For best quality:**
1. **Use larger models**: llama3.3:70b, qwen2.5-coder:32b
2. **Accept slower speed**: Worth it for complex tasks
3. **Let model load fully**: First response is slower

**Monitor performance:**
```bash
btop
```
Watch RAM and GPU usage in real-time.

---

### When You Have Limited RAM

**If responses are slow or system freezes:**

**Use smaller models:**
- Switch from 70B → 32B → 7B models
- Example: llama3.3:70b → mistral:7b

**Close other apps:**
- Close browsers (use lots of RAM)
- Close VS Code if not needed
- Exit games or media players

**One model at a time:**
- Don't run multiple AI sessions
- Exit one before starting another

---

## Troubleshooting

### "Model not found" Error

**Problem:** You tried to use a model that's not downloaded.

**Solution:**
```bash
ollama pull <model-name>
```

**Check available models:**
```bash
ollama list
```

---

### "Out of Memory" Error

**Problem:** Model is too large for available RAM.

**Solutions:**

1. **Try a smaller model:**
   ```bash
   ollama run mistral:7b
   ```

2. **Close other applications**

3. **Check memory usage:**
   ```bash
   free -h
   htop
   ```

4. **Use quantized models** (coming soon)

---

### Download Interrupted

**Problem:** Download stopped or failed.

**Solution:** Ollama auto-resumes! Just run the same command again:
```bash
ollama pull model-name
```

It will continue from where it left off.

---

### Model Runs But Gives Weird Responses

**Problem:** Model corruption or wrong model for task.

**Solutions:**

1. **Re-download the model:**
   ```bash
   ollama rm problematic-model
   ollama pull problematic-model
   ```

2. **Try a different model:**
   Maybe this model isn't good at your specific task

3. **Check your prompt:**
   Be more specific in your questions

---

### Ollama Service Won't Start

**Problem:** `ollama: command not found` or service errors.

**Solution:**

1. **Start the service:**
   ```bash
   sudo systemctl start ollama
   ```

2. **Enable auto-start:**
   ```bash
   sudo systemctl enable ollama
   ```

3. **Check service status:**
   ```bash
   sudo systemctl status ollama
   ```

4. **View logs:**
   ```bash
   sudo journalctl -u ollama -f
   ```

---

### Slow Download Speeds

**Problem:** Model takes forever to download.

**Solutions:**

1. **Check internet connection:**
   ```bash
   ping google.com
   speedtest-cli
   ```

2. **Use wired connection** instead of WiFi

3. **Download during off-peak hours**

4. **Be patient**: Large models (70B) can take 30-60 minutes

---

## Advanced: Custom Models

### Creating Model Variants

You can create customized versions of models with specific behaviors:

**Example: Create a "helpful teacher" variant:**

1. **Create a Modelfile:**
```bash
nano ~/TeacherModel
```

2. **Add configuration:**
```
FROM qwen2.5-coder:32b

PARAMETER temperature 0.8
PARAMETER top_p 0.9

SYSTEM """
You are a patient and encouraging programming teacher. 
When explaining concepts:
1. Use simple language
2. Provide examples
3. Encourage the student
4. Ask if they understand before moving on
"""
```

3. **Create the model:**
```bash
ollama create teacher-coder:32b -f ~/TeacherModel
```

4. **Use it:**
```bash
ollama run teacher-coder:32b
```

---

## Quick Reference Commands

### Essential Commands

```bash
# List all models
ollama list

# Download a model
ollama pull model-name

# Run/chat with a model
ollama run model-name

# Delete a model
ollama rm model-name

# Show model info
ollama show model-name

# Check service status
sudo systemctl status ollama

# Start service
sudo systemctl start ollama

# View logs
sudo journalctl -u ollama -f
```

---

## Recommended First Downloads

**Start with these 3 models** (covers most use cases):

```bash
# 1. Best coding model (18GB)
ollama pull qwen2.5-coder:32b

# 2. Fast general model (4GB)
ollama pull mistral:7b

# 3. Best large model (38GB) - optional but recommended
ollama pull llama3.3:70b
```

**Total: ~60GB** - leaves plenty of room for more!

---

## Getting Help

**Commands:**
```bash
ollama --help              # General help
ollama pull --help         # Help for specific command
qalarc-explain             # Interactive help system
```

**Online Resources:**
- Official Ollama docs: https://ollama.ai/
- Model library: https://ollama.ai/library
- Qalarc community: https://qalarc.com

**Check model library:**
Browse available models at https://ollama.ai/library

---

## Next Steps

Now that you understand Ollama:

1. **[AI_CODING_TUTORIAL.md](./AI_CODING_TUTORIAL.md)** - Use your models with OpenCode
2. **[KEYBOARD_SHORTCUTS.md](./KEYBOARD_SHORTCUTS.md)** - Work more efficiently
3. **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** - Fix common issues

**Experiment!** Try different models and find your favorites. There's no "wrong" choice - it's about what works best for YOUR tasks.

---

**Happy AI modeling!** 🤖

*Remember: Larger doesn't always mean better. Choose models based on your actual needs.*

*Last updated: January 2026*
