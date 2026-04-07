# AI-Playground Quick Start

Get up and running in 5 minutes!

## 🚀 One-Line Install

### Step 1: Check Prerequisites (Optional)

```bash
curl -fsSL https://raw.githubusercontent.com/juvaraju-hub/AI-Playground/main/scripts/check-prerequisites.sh | bash
```

This shows what's installed and what's missing. Not required, but helpful!

### Step 2: Install

```bash
curl -fsSL https://raw.githubusercontent.com/juvaraju-hub/AI-Playground/main/scripts/install.sh | bash
```

That's it! The installer will:
- ✅ Check prerequisites
- ✅ Clone the repository
- ✅ Install tools (claude-start, codex-start)
- ✅ Optionally set up MCP servers
- ✅ Add shell aliases

## 🎯 After Installation

### 1. Reload Your Shell
```bash
source ~/.zshrc  # or ~/.bashrc
```

### 2. Verify
```bash
# Check if tools are installed
which claude-start
which codex-start

# Run help
claude-start --help
codex-start --help
```

### 3. First Run

#### For Claude Code:
```bash
# Run preflight checks
claude-start --check-only

# Set up OAuth MCPs
claude-start --refresh-mcp

# Launch Claude with checks
claude-start
```

#### For Codex:
```bash
# Run preflight checks
codex-start --check-only

# Set up OAuth MCPs
codex-start --refresh-mcp

# Launch Codex with checks
codex-start
```

## 📝 Using Aliases

If you added aliases during installation:

```bash
# Claude Code
ccx                 # Launch with checks
ccx-check           # Check only
ccx-mcp             # OAuth setup

# Codex
cx                  # Launch with checks
cx-check            # Check only
cx-mcp              # OAuth setup
```

## 🔐 MCP OAuth Setup

When you run `--refresh-mcp`, you'll be asked for each OAuth server individually:

```bash
$ claude-start --refresh-mcp

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Server: Atlassian (Jira/Confluence)
Status: Needs authentication
Usage: Ask: 'Search my Jira issues'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Authenticate Atlassian (Jira/Confluence) now? (y/N) y
  ✓ OAuth completed

# Continue for each server...
```

**You control which servers to authenticate now vs later!**

## 📚 Next Steps

### Learn More
- [Full Installation Guide](INSTALL.md) - Detailed setup instructions
- [MCP Setup Guide](docs/mcp-setup/INDEX.md) - MCP configuration
- [OAuth Guide](docs/mcp-setup/OAUTH_GUIDE.md) - OAuth details

### Daily Usage
```bash
# Morning routine
claude-start --refresh-mcp
codex-start --refresh-mcp

# Quick launch
ccx
cx

# Just check status
ccx-check
cx-check
```

### In Claude/Codex
```bash
# Use skills
/claude-start
/claude-start --refresh-mcp
/claude-start --full

/codex-start
/codex-start --refresh-mcp
/codex-start --full
```

## 🛠️ Common Tasks

### Update Installation
```bash
cd ~/ai-playground  # or wherever you installed
git pull origin main

# Re-install tools
cd tools/claude-start && ./install.sh
cd tools/codex-start && ./install.sh
```

### Re-register MCPs
```bash
cd ~/ai-playground/docs/mcp-setup
./register-mcps.sh
```

### Check MCP Status
```bash
claude mcp list  # For Claude Code
codex mcp list   # For Codex
```

### Verify Everything
```bash
~/ai-playground/docs/mcp-setup/verify-mcps.sh
```

## ⚙️ Configuration

### Set Tokens (if needed)

```bash
# GitHub (for GitHub MCP)
export GITHUB_PAT_TOKEN=$(gh auth token)

# Terraform Cloud
export TFC_TOKEN="your-token"

# Add to shell config for persistence
echo 'export GITHUB_PAT_TOKEN=$(gh auth token 2>/dev/null)' >> ~/.zshrc
```

### Environment Variables

Create `~/.ai-playground.env`:
```bash
export CODEX_START_AWS_PROFILE="your-profile"
export CODEX_START_KUBE_CONTEXTS="prod staging"
export CODEX_START_REFRESH_MCP=1  # Auto-refresh
```

Then source it:
```bash
echo 'source ~/.ai-playground.env' >> ~/.zshrc
```

## 🐛 Troubleshooting

### Command not found
```bash
# Check PATH
echo $PATH | grep "$HOME/bin"

# Add to PATH if needed
export PATH="$HOME/bin:$PATH"

# Reload shell
source ~/.zshrc
```

### MCPs not showing
```bash
# Re-register
cd ~/ai-playground/docs/mcp-setup
./register-mcps.sh

# Verify
claude mcp list
```

### OAuth not working
```bash
# Manually via Codex (if available)
codex mcp login atlassian

# Or wait for Claude to prompt when used
```

## 🎉 That's It!

You're ready to go! For more details, see:
- [INSTALL.md](INSTALL.md) - Full installation guide
- [README.md](README.md) - Project overview
- [docs/mcp-setup/](docs/mcp-setup/) - MCP documentation

**Questions?** Check the [troubleshooting section](INSTALL.md#troubleshooting) or open an issue.

---

**Happy coding!** 🚀
