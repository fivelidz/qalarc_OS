# AI Coding Assistant Tutorial

**Learn how to use AI to help you code, understand projects, and solve problems - even if you've never programmed before!**

This guide covers everything from basic usage to advanced workflows.

---

## Table of Contents

1. [What is AI Coding?](#what-is-ai-coding)
2. [Available AI Tools](#available-ai-tools)
3. [Quick Start: "Open in AI"](#quick-start-open-in-ai)
4. [Claude Code vs OpenCode](#claude-code-vs-opencode)
5. [Step-by-Step Tutorials](#step-by-step-tutorials)
6. [Example Workflows](#example-workflows)
7. [TMUX Basics](#tmux-basics)
8. [Keyboard Shortcuts](#keyboard-shortcuts)
9. [Tips and Best Practices](#tips-and-best-practices)

---

## What is AI Coding?

**AI coding assistants** are like having an experienced programmer sitting next to you, ready to help 24/7.

**They can help you:**
- ✅ Understand what code does (explain existing projects)
- ✅ Write new code from descriptions ("make a calculator app")
- ✅ Find and fix bugs (debug errors)
- ✅ Learn programming concepts (tutorials on demand)
- ✅ Refactor code (make it cleaner and faster)
- ✅ Answer technical questions

**What makes Qalarc special:**
- **Privacy**: AI runs on YOUR computer (no cloud required)
- **No limits**: No usage caps or API costs
- **Fast**: Direct access to your 96GB AI memory
- **Offline**: Works without internet (after initial model download)

---

## Available AI Tools

Qalarc comes with **three AI coding tools**:

### 1. **Claude Code** (Cloud-based)

**What it is**: Anthropic's official AI coding assistant

**Pros:**
- Most capable model (Claude 3.5 Sonnet)
- Best for complex reasoning and explanations
- Official support and frequent updates

**Cons:**
- Requires internet connection
- Needs API key (paid, but has free tier)
- Sends your code to Anthropic's servers

**When to use**: Complex problems, learning new concepts, architectural planning

### 2. **OpenCode** (Local AI - Recommended)

**What it is**: Open-source AI coding assistant that runs locally

**Pros:**
- 100% private (never leaves your computer)
- No API costs (free forever)
- Works offline
- Fast on your hardware

**Cons:**
- Slightly less capable than Claude (but getting better!)
- Needs local AI models (see [OLLAMA_MODELS_GUIDE.md](./OLLAMA_MODELS_GUIDE.md))

**When to use**: Daily coding, privacy-sensitive projects, offline work

### 3. **Direct Ollama Chat**

**What it is**: Chat directly with AI models via terminal

**Pros:**
- Simplest interface
- Great for quick questions
- Very fast responses

**Cons:**
- No file editing capabilities
- Basic terminal interface
- Manual copy/paste needed

**When to use**: Quick questions, learning, brainstorming

---

## Quick Start: "Open in AI"

The **easiest way** to use AI coding on Qalarc is the right-click menu.

### Step-by-Step: Your First AI Session

**1. Find a folder** you want to work on (or create a test folder):

```bash
mkdir ~/my-first-ai-project
cd ~/my-first-ai-project
echo "# My Test Project" > README.md
```

[SCREENSHOT: Dolphin file manager with folder created]

**2. Open the file manager** (Dolphin):
- Click the folder icon in your taskbar
- Navigate to `Home`
- Find your `my-first-ai-project` folder

**3. Right-click the folder**
- A context menu appears
- Look for **"Open in AI"** option
- Click it!

[SCREENSHOT: Right-click menu with "Open in AI" highlighted]

**4. Choose your AI tool:**

A dialog appears with three options:
- **OpenCode (Local Models - Offline)** ← Recommended for beginners
- **Claude Code (Cloud - Requires API Key)**
- **Just Chat (Ollama Direct)**

**Select "OpenCode"** for now.

**5. Choose a coding style (agent):**

Another dialog appears:
- **Coder**: Best for writing new code
- **Architect**: Best for planning and design
- **Reviewer**: Best for code review
- **Debugger**: Best for finding bugs
- **Default**: General-purpose assistant

**Select "Coder"** for this tutorial.

**6. Choose an AI model:**

A list of available models appears:
- **auto**: Uses the recommended default
- **qwen2.5-coder:32b**: Great coding model (18GB)
- **llama3.3:70b**: Powerful general model (38GB)
- **mistral:7b**: Fast, small model (4GB)

**Select "auto"** (or pick a model you've downloaded).

**7. Wait for terminal to open**

Ghostty (the terminal) opens with OpenCode running!

[SCREENSHOT: OpenCode running in Ghostty terminal]

**8. Start chatting!**

Type your first message:
```
Hello! Can you explain what files are in this folder?
```

Press Enter and watch the AI analyze your project!

---

## Claude Code vs OpenCode

### Side-by-Side Comparison

| Feature | Claude Code | OpenCode |
|---------|-------------|----------|
| **Privacy** | Cloud (Anthropic servers) | 100% Local |
| **Internet Required** | Yes | No (after model download) |
| **Cost** | $20/month or pay-per-use | Free forever |
| **Capability** | Excellent | Very Good |
| **Speed** | Fast (depends on internet) | Very Fast (local) |
| **Model** | Claude 3.5 Sonnet | Your choice (Qwen, Llama, etc.) |
| **Setup** | API key needed | Just install models |
| **Use Case** | Complex reasoning | Daily coding |

### When to Use Each

**Use Claude Code for:**
- Learning new complex concepts
- Architectural design decisions
- Refactoring large codebases
- When you need the absolute best reasoning

**Use OpenCode for:**
- Daily coding tasks
- Private/sensitive projects
- Working offline (travel, airplane, etc.)
- Avoiding API costs

**Pro Tip**: Use both! Claude for planning, OpenCode for implementation.

---

## Step-by-Step Tutorials

### Tutorial 1: "Help Me Understand This Code"

**Scenario**: You found a script online and want to know what it does.

**1. Save the code to a file:**

```bash
mkdir ~/code-to-understand
cd ~/code-to-understand
cat > mystery-script.py << 'EOF'
import sys

def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

if __name__ == "__main__":
    num = int(sys.argv[1])
    print(f"Fibonacci({num}) = {fibonacci(num)}")
EOF
```

**2. Open in AI:**
- Right-click the `code-to-understand` folder
- Select "Open in AI" → OpenCode → Architect → auto

**3. Ask the AI:**
```
Can you explain what mystery-script.py does? 
Please explain it like I'm a beginner.
```

**4. The AI will:**
- Read the file
- Explain what a Fibonacci sequence is
- Describe how the code works
- Point out any issues (like inefficiency in this recursive version)

**5. Follow-up questions:**
```
How could this code be improved?
Can you show me a better version?
What are command line arguments?
```

---

### Tutorial 2: "Fix This Bug"

**Scenario**: Your code has an error and you don't know why.

**1. Create a buggy script:**

```bash
mkdir ~/debug-practice
cd ~/debug-practice
cat > broken-calculator.py << 'EOF'
def add(a, b):
    return a + b

def divide(a, b):
    return a / b

# Test the calculator
print("5 + 3 =", add(5, 3))
print("10 / 2 =", divide(10, 2))
print("8 / 0 =", divide(8, 0))  # This will crash!
EOF
```

**2. Try running it:**
```bash
python broken-calculator.py
```

You'll see an error: `ZeroDivisionError: division by zero`

**3. Open in AI:**
- Right-click `debug-practice` folder
- Select "Open in AI" → OpenCode → Debugger

**4. Share the error with AI:**
```
I'm getting this error when running broken-calculator.py:

ZeroDivisionError: division by zero

Can you help me fix it?
```

**5. The AI will:**
- Identify the problem (dividing by zero)
- Explain why it happens
- Suggest solutions (add error checking)
- Show you the fixed code

**6. Implement the fix:**
- AI will show you the corrected code
- Copy the fixed version
- Save to file
- Test again!

---

### Tutorial 3: "Create a New Feature"

**Scenario**: You want to build something from scratch.

**1. Start with an idea:**

```bash
mkdir ~/weather-app
cd ~/weather-app
```

**2. Open in AI:**
- Right-click `weather-app` folder
- Select "Open in AI" → OpenCode → Coder

**3. Describe what you want:**
```
I want to create a simple weather app that:
1. Asks the user for a city name
2. Shows the current temperature
3. Shows if it's sunny, rainy, or cloudy

Can you help me build this? I'm a beginner, so please explain each step.
```

**4. The AI will:**
- Ask clarifying questions (do you want to use a weather API?)
- Break down the project into steps
- Write code with comments
- Explain how to run it
- Suggest improvements

**5. Follow along:**
- Read the AI's explanations
- Copy code into files as directed
- Ask questions when confused
- Test each step

**Example interaction:**
```
AI: I'll help you create a weather app! First, let's start with a 
    simple version that asks for a city and prints a mock response. 
    Later we can add real weather data.

    Create a file called weather.py:
    [shows code]

You: How do I create a file?

AI: Great question! Use this command:
    nano weather.py
    
    Then paste the code I showed, press Ctrl+O to save, 
    and Ctrl+X to exit.

You: Got it! What's next?
```

---

## Example Workflows

### Workflow 1: Learning a New Programming Language

**Goal**: Learn Python basics with AI help

```
You: I want to learn Python. Can you teach me the basics?

AI: I'd be happy to teach you Python! Let's start with the fundamentals...
    [provides tutorial]

You: Can you create a simple exercise for me to practice?

AI: Sure! Here's an exercise: Create a program that asks for your name 
    and age, then tells you how old you'll be in 10 years...
    [provides template]

You: [completes exercise]
    Here's my solution: [pastes code]
    Did I do it right?

AI: Great job! Your code works. Here are a few suggestions to improve it...
```

**Result**: Personalized learning at your own pace!

---

### Workflow 2: Understanding an Existing Project

**Goal**: Understand a GitHub project you cloned

**1. Clone a project:**
```bash
cd ~/projects
git clone https://github.com/example/some-project.git
cd some-project
```

**2. Open in AI:**
- Right-click project folder
- Open in AI → OpenCode → Architect

**3. Have a conversation:**
```
You: I just cloned this project but I don't understand how it works. 
     Can you give me an overview?

AI: [analyzes files]
    This appears to be a web application built with Flask (Python). 
    Let me break down the structure...
    
    Main files:
    - app.py: The main application entry point
    - templates/: HTML pages for the website
    - static/: CSS and JavaScript files
    ...

You: What does app.py do?

AI: [reads app.py]
    The app.py file does three main things:
    1. Sets up a Flask web server
    2. Defines routes (URLs your app responds to)
    3. Handles user requests
    
    Let me show you each part...

You: How do I run this project?

AI: To run this project, you'll need to:
    1. Install dependencies: pip install -r requirements.txt
    2. Run the app: python app.py
    3. Open browser to: http://localhost:5000
```

**Result**: You now understand the project structure and how to use it!

---

### Workflow 3: Code Review and Improvement

**Goal**: Get feedback on your code

**1. Write some code** (your first attempt):

```python
# my-script.py
names = ["Alice", "Bob", "Charlie"]
ages = [25, 30, 35]

for i in range(len(names)):
    print(names[i] + " is " + str(ages[i]) + " years old")
```

**2. Open in AI:**
- Right-click folder → Open in AI → Reviewer

**3. Ask for feedback:**
```
You: I wrote this script. Can you review it and suggest improvements?

AI: Your code works, but here are some suggestions to make it more 
    "Pythonic" (following Python best practices):
    
    1. Use zip() instead of range(len(...))
    2. Use f-strings for cleaner string formatting
    3. Consider using a dictionary for name-age pairs
    
    Here's an improved version:
    
    # Better version
    names = ["Alice", "Bob", "Charlie"]
    ages = [25, 30, 35]
    
    for name, age in zip(names, ages):
        print(f"{name} is {age} years old")
    
    Or even better with a dictionary:
    
    people = {
        "Alice": 25,
        "Bob": 30,
        "Charlie": 35
    }
    
    for name, age in people.items():
        print(f"{name} is {age} years old")

You: Why is the dictionary version better?

AI: Great question! Here's why...
    [detailed explanation]
```

**Result**: Learn best practices and improve your coding style!

---

## TMUX Basics

**TMUX** is a "terminal multiplexer" - it lets you split your terminal into multiple panes and windows.

### Why Use TMUX?

**Without TMUX**: You need many terminal windows open (messy!)

**With TMUX**: Everything in one window, split into organized panes.

[SCREENSHOT: TMUX layout with multiple panes]

### TMUX Key Concepts

**1. Prefix Key**: `Ctrl+A`
- Press `Ctrl+A`, release, then press another key for commands
- Think of it as "hey TMUX, I'm about to give you a command"

**2. Panes**: Splits within a window
- Like tiling windows inside your terminal
- Navigate with `Alt + arrow keys` (NO prefix needed!)

**3. Windows**: Separate tabs
- Like browser tabs but for terminals
- Switch with `Shift + left/right arrows`

**4. Sessions**: Entire workspaces
- Can detach (closes terminal but keeps everything running)
- Reattach later to resume exactly where you left off

### Essential TMUX Commands

| Command | Action | Notes |
|---------|--------|-------|
| `Ctrl+A` then `\|` | Split vertically | Creates left/right panes |
| `Ctrl+A` then `-` | Split horizontally | Creates top/bottom panes |
| `Alt + ←→↑↓` | Switch panes | No prefix needed! |
| `Ctrl+A` then `o` | Open Claude Code | In new pane |
| `Ctrl+A` then `O` | Open OpenCode | In new pane |
| `Ctrl+A` then `x` | Close current pane | No confirmation |
| `Ctrl+A` then `c` | New window | Like a new tab |
| `Shift + ←→` | Switch windows | No prefix needed |
| `Ctrl+A` then `d` | Detach session | Keeps running in background |
| `tmux a` | Reattach to session | Resume your work |

### TMUX Tutorial: AI Workspace

**The AI Workspace** is a pre-configured TMUX layout perfect for coding.

**Launch it:**
```bash
qalarc-ai-workspace
```

**You'll see three panes:**

```
┌─────────────────────────────────────────┬──────────────┐
│                                         │              │
│   AI Chat (Main Pane)                  │   System     │
│   - Chat with AI here                   │   Monitor    │
│   - Get code suggestions                │   (btop)     │
│   - Ask questions                       │              │
│                                         │              │
├─────────────────────────────────────────┼──────────────┤
│   Command Runner / File Viewer          │              │
│   - Run commands suggested by AI        │              │
│   - Test code snippets                  │              │
│   - View files with: bat, cat, less     │              │
└─────────────────────────────────────────┴──────────────┘
```

**Typical workflow:**
1. **Top-left pane**: Chat with AI, ask questions
2. **Top-right pane**: Monitor system resources (automatic)
3. **Bottom-left pane**: Run commands AI suggests

**Example session:**
```
[Top-left pane - AI Chat]
You: Create a Python script that calculates factorial

AI: Here's a factorial calculator:
    [shows code]
    
    Save this to factorial.py and run: python factorial.py

[Bottom-left pane - Command Runner]
$ nano factorial.py
[paste code from AI]
[save: Ctrl+O, exit: Ctrl+X]

$ python factorial.py
Enter a number: 5
Factorial of 5 is 120

[Switch back to AI pane with Alt+Up]
You: Great! How can I make it handle errors?
```

### Detaching and Reattaching

**Why detach?**
- Close your terminal but keep work running
- Resume later exactly where you left off
- Like "minimizing" but for entire terminal sessions

**To detach:**
Press `Ctrl+A` then `d`

**To reattach:**
```bash
tmux attach-session -t qalarc-ai
```

**Check what sessions are running:**
```bash
tmux list-sessions
```

---

## Keyboard Shortcuts

### AI-Specific Shortcuts

| Shortcut | Action |
|----------|--------|
| `Super + A` | Quick AI access (launcher) |
| `Ctrl+A` then `o` | Open Claude Code in TMUX pane |
| `Ctrl+A` then `O` | Open OpenCode in TMUX pane |

### TMUX Shortcuts (Full List)

See [KEYBOARD_SHORTCUTS.md](./KEYBOARD_SHORTCUTS.md) for complete reference.

**Most important ones:**

| Shortcut | Action |
|----------|--------|
| `Alt + Arrows` | Navigate panes (no prefix!) |
| `Shift + ←→` | Switch windows (no prefix!) |
| `Ctrl+A` then `-` | Split horizontal |
| `Ctrl+A` then `\|` | Split vertical |
| `Ctrl+A` then `x` | Close pane |
| `Ctrl+A` then `d` | Detach session |

### Terminal Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl + C` | Cancel current command |
| `Ctrl + L` | Clear screen |
| `Ctrl + R` | Search command history |
| `Ctrl + A` | Move to start of line |
| `Ctrl + E` | Move to end of line |
| `Tab` | Auto-complete |
| `↑ ↓` | Browse command history |

---

## Tips and Best Practices

### Getting Better Answers from AI

**1. Be specific:**
- ❌ "Fix my code"
- ✅ "I'm getting a 'list index out of range' error on line 23. Can you help?"

**2. Provide context:**
- ❌ "How do I read files?"
- ✅ "I'm writing a Python script that needs to read CSV files. How do I do that?"

**3. Ask for explanations:**
- ✅ "Can you explain WHY this solution works?"
- ✅ "What are the pros and cons of this approach?"

**4. Break down complex tasks:**
- ❌ "Build me a complete web app"
- ✅ "Let's start with a simple Flask app. First, how do I set up routing?"

**5. Iterate:**
```
You: Create a calculator
AI: [shows basic calculator]
You: Can you add square root support?
AI: [adds square root]
You: Can you make the output prettier?
AI: [improves formatting]
```

### Choosing the Right Model

**For coding tasks:**
- **qwen2.5-coder:32b** - Best coding model (18GB) ⭐ Recommended
- **deepseek-coder:33b** - Alternative coding model (20GB)
- **codellama:34b** - Meta's coding model (20GB)

**For general help:**
- **llama3.3:70b** - Most capable general model (38GB)
- **mistral:7b** - Fast, good for quick questions (4GB)

**See [OLLAMA_MODELS_GUIDE.md](./OLLAMA_MODELS_GUIDE.md) for full list and download instructions.**

### Workflow Recommendations

**For learning:**
1. Use OpenCode with qwen2.5-coder:32b
2. Ask for step-by-step explanations
3. Request exercises to practice
4. Don't copy/paste - type code yourself to learn better

**For professional work:**
1. Use Claude Code for architecture planning
2. Switch to OpenCode for implementation
3. Use Reviewer agent for code review
4. Test everything in the TMUX command pane

**For debugging:**
1. Use Debugger agent in OpenCode
2. Provide full error messages
3. Share relevant code context
4. Try suggested solutions incrementally

### Privacy Considerations

**OpenCode (Local):**
- ✅ Never sends data anywhere
- ✅ Safe for proprietary code
- ✅ Works offline
- ✅ No usage tracking

**Claude Code:**
- ⚠️ Sends code to Anthropic servers
- ⚠️ Review their privacy policy
- ⚠️ Don't use with sensitive/proprietary code
- ✅ Data used to improve models (can opt out)

**Recommendation**: Use OpenCode by default, Claude Code only for non-sensitive projects.

---

## Troubleshooting AI Tools

### "Model not found"

**Solution:** Download the model first
```bash
ollama pull qwen2.5-coder:32b
```

### "Ollama is not running"

**Solution:** Start the service
```bash
sudo systemctl start ollama
```

### "OpenCode won't start"

**Solution:** Check if OpenCode is installed
```bash
which opencode
```
If not found, reinstall system or check installation.

### "Responses are too slow"

**Solutions:**
1. Use a smaller model (mistral:7b instead of llama3.3:70b)
2. Close other applications to free RAM
3. Check system monitor (btop) - is RAM/CPU maxed?

### "AI gives incorrect information"

**Remember:** AI assistants are not perfect!

**Always:**
- ✅ Test code before using in production
- ✅ Verify facts from official documentation
- ✅ Ask AI to explain its reasoning
- ✅ Use AI as a starting point, not the final answer

---

## Next Steps

**Now you know the basics!** Here's what to explore next:

1. **Download more models**: [OLLAMA_MODELS_GUIDE.md](./OLLAMA_MODELS_GUIDE.md)
2. **Learn shortcuts**: [KEYBOARD_SHORTCUTS.md](./KEYBOARD_SHORTCUTS.md)
3. **Customize your setup**: Edit `~/.tmux.conf` for custom TMUX config
4. **Join community**: Share your AI coding experiences

**Practice project ideas:**
- Build a to-do list app with AI help
- Create a personal website
- Make a game (tic-tac-toe, guessing game)
- Automate a boring task with a script

---

## Resources

**Official Documentation:**
- Claude Code: https://claude.ai/docs
- OpenCode: Built-in (`opencode --help`)
- Ollama: https://ollama.ai/

**Getting Help:**
```bash
qalarc-explain          # Interactive help system
claude --help           # Claude Code help
opencode --help         # OpenCode help
ollama --help          # Ollama help
```

**Community:**
- Qalarc forums: https://qalarc.com/community
- Email: team@qalarc.com

---

**Happy coding with AI!** 🚀

*Remember: The best way to learn is by doing. Start with simple projects and gradually increase complexity.*

*Last updated: January 2026*
