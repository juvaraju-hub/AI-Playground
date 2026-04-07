# AI-Playground Installation Guide

Complete step-by-step guide to install AI-Playground tools and skills for your team.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Install (Recommended)](#quick-install-recommended)
- [Manual Installation](#manual-installation)
- [What Gets Installed](#what-gets-installed)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

---

## 📋 Prerequisites

### Quick Check

Run this to check what's installed:

```bash
curl -fsSL https://raw.githubusercontent.com/juvaraju-hub/AI-Playground/main/scripts/check-prerequisites.sh | bash
```

This will show you what's missing and provide installation commands.

### Required

1. **Claude Code** or **Codex** installed
   ```bash
   # Check if installed
   which claude  # For Claude Code
   which codex   # For Codex
   ```
   - Install Claude Code: https://claude.ai/download
   - Install Codex: Contact your team admin

2. **Git**
   ```bash
   git --version  # Should be 2.0+
   ```

3. **Shell**: bash or zsh
   ```bash
   echo $SHELL
   ```

### Optional but Recommended

4. **GitHub CLI** (for MCP authentication)
   ```bash
   # macOS
   brew install gh
   
   # Linux
   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
   ```

5. **AWS CLI** (for cloud checks)
   ```bash
   # macOS
   brew install awscli
   
   # Linux
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   ```

6. **kubectl** (for Kubernetes checks)
   ```bash
   # macOS
   brew install kubectl
   
   # Linux
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   ```

7. **uv** (for Python MCP servers)
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

8. **npx/npm** (for NPX MCP servers)
   ```bash
   # macOS
   brew install node
   
   # Linux
   curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

---

## 🚀 Quick Install (Recommended)

### One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/juvaraju-hub/AI-Playground/main/scripts/install.sh | bash
```

This will:
1. Clone the repository
2. Install claude-start launcher
3. Install codex-start launcher
4. Set up MCP servers
5. Configure shell aliases
6. Verify installation

### What You'll Be Asked

The installer will prompt you for:
- Installation directory (default: `~/bin`)
- Shell config file (default: `~/.zshrc` or `~/.bashrc`)
- Whether to install MCP servers
- Whether to set up shell aliases

---

## 📦 Manual Installation

### Step 1: Clone Repository

```bash
# Clone to your preferred location
cd ~
git clone https://github.com/juvaraju-hub/AI-Playground.git
cd AI-Playground
```

### Step 2: Install claude-start (Claude Code users)

```bash
cd tools/claude-start
./install.sh
```

**What it does:**
- Installs `claude-start` to `~/bin/`
- Adds `~/bin` to PATH (if needed)
- Suggests shell aliases

**Verify:**
```bash
which claude-start
claude-start --help
```

### Step 3: Install codex-start (Codex users)

```bash
cd tools/codex-start
./install.sh
```

**What it does:**
- Installs `codex-start` to `~/bin/`
- Adds `~/bin` to PATH (if needed)
- Suggests shell aliases

**Verify:**
```bash
which codex-start
codex-start --help
```

### Step 4: Set Up MCP Servers (Claude Code)

```bash
cd docs/mcp-setup
./register-mcps.sh
```

**What it does:**
- Registers 14 MCP servers in Claude Code
- Configures OAuth servers (atlassian, webexapis, datadog, etc.)
- Sets up STDIO servers (kubernetes, terraform, etc.)

**Note:** You'll need tokens for some servers:
- `TFC_TOKEN` for Terraform Cloud
- `GITHUB_PAT_TOKEN` for GitHub MCP

**Verify:**
```bash
claude mcp list
```

### Step 5: Add Shell Aliases (Optional)

Add to `~/.zshrc` or `~/.bashrc`:

```bash
# Claude Code
alias ccx='claude-start'
alias ccx-check='claude-start --check-only'
alias ccx-mcp='claude-start --refresh-mcp'

# Codex
alias cx='codex-start'
alias cx-check='codex-start --check-only'
alias cx-mcp='codex-start --refresh-mcp'
```

Then reload:
```bash
source ~/.zshrc  # or ~/.bashrc
```

### Step 6: Install Skills (Optional)

#### For Claude Code:
```bash
# Copy to global skills directory
mkdir -p ~/.claude/skills
cp -r .claude/skills/* ~/.claude/skills/

# Or symlink
ln -s ~/AI-Playground/.claude/skills/* ~/.claude/skills/
```

#### For Codex:
```bash
# Copy to global skills directory
mkdir -p ~/.codex/skills
cp -r .codex/skills/* ~/.codex/skills/

# Or symlink
ln -s ~/AI-Playground/.codex/skills/* ~/.codex/skills/
```

---

## 📦 What Gets Installed

### Tools

| Tool | Location | Purpose |
|------|----------|---------|
| `claude-start` | `~/bin/claude-start` | Claude Code preflight launcher |
| `codex-start` | `~/bin/codex-start` | Codex preflight launcher |

### MCP Servers (Claude Code - 14 total)

#### OAuth Servers (5)
- **atlassian** - Jira/Confluence integration
- **webexapis** - Cisco Webex APIs
- **datadog_us** - Datadog US region
- **datadog_eu** - Datadog EU region
- **argocd-sbx** - ArgoCD Sandbox

#### Passive Servers (9)
- **github** - GitHub API
- **context7** - Context management
- **terraform** - Terraform with env file
- **terraform-cloud** - Terraform Cloud
- **victorops** - VictorOps/Splunk On-Call
- **aws-knowledge-mcp-server** - AWS documentation
- **openaiDeveloperDocs** - OpenAI documentation
- **kubernetes** - Kubernetes management
- **chrome-devtools** - Chrome DevTools protocol

### Skills

| Skill | Location | Usage |
|-------|----------|-------|
| claude-start | `.claude/skills/claude-start/` | `/claude-start` |
| codex-start | `.codex/skills/codex-start/` | `/codex-start` |

### Documentation

All documentation is in `docs/mcp-setup/`:
- [INDEX.md](docs/mcp-setup/INDEX.md) - Documentation index
- [SETUP_COMPLETE.md](docs/mcp-setup/SETUP_COMPLETE.md) - Complete setup guide
- [OAUTH_GUIDE.md](docs/mcp-setup/OAUTH_GUIDE.md) - OAuth authentication
- [QUICKSTART.txt](docs/mcp-setup/QUICKSTART.txt) - Quick reference

---

## ✅ Verification

### 1. Check Tools

```bash
# Claude Code
which claude-start
claude-start --version  # or --help

# Codex
which codex-start
codex-start --version  # or --help
```

### 2. Check MCP Servers

```bash
# Claude Code
claude mcp list

# Codex
codex mcp list
```

### 3. Run Preflight Checks

```bash
# Claude Code
claude-start --check-only

# Codex
codex-start --check-only
```

### 4. Test OAuth (Claude Code)

```bash
claude-start --refresh-mcp

# You'll be asked for each OAuth server:
# → Authenticate Atlassian? (y/N)
# → Authenticate Webex? (y/N)
# → etc.
```

---

## 🎯 Quick Start After Installation

### Daily Workflow

```bash
# Start of day - run checks and launch
claude-start
# or
codex-start

# With OAuth refresh
claude-start --refresh-mcp
codex-start --refresh-mcp
```

### Using Skills in Claude/Codex

```bash
# In Claude or Codex prompt:
/claude-start
/claude-start --refresh-mcp
/claude-start --full

/codex-start
/codex-start --refresh-mcp
/codex-start --full
```

---

## 🔧 Configuration

### Environment Variables

Create `~/.ai-playground.env`:

```bash
# AWS
export CODEX_START_AWS_PROFILE="your-profile"
export AWS_PROFILE="your-profile"

# Kubernetes
export CODEX_START_KUBE_CONTEXTS="prod staging"

# MCP OAuth servers
export CODEX_START_MCP_OAUTH_SERVERS="atlassian webexapis datadog_us datadog_eu"

# MCP Passive servers
export CODEX_START_MCP_PASSIVE_SERVERS="github context7 terraform terraform-cloud victorops aws-knowledge-mcp-server openaiDeveloperDocs kubernetes chrome-devtools"

# Auto-refresh MCPs
export CODEX_START_REFRESH_MCP=0  # Set to 1 to always refresh

# Open AWS console after auth
export CODEX_START_OPEN_AWS_CONSOLE=0  # Set to 1 to auto-open

# Use AWS Bedrock (Claude Code)
export CODEX_START_USE_BEDROCK=1
```

Then source it:
```bash
echo 'source ~/.ai-playground.env' >> ~/.zshrc
source ~/.zshrc
```

### MCP Tokens

Set these environment variables or add to your shell config:

```bash
# GitHub (for GitHub MCP)
export GITHUB_PAT_TOKEN=$(gh auth token)

# Terraform Cloud (for terraform-cloud MCP)
export TFC_TOKEN="your-tfc-token"

# Or create env files:
# ~/.config/codex/mcp-terraform.env
# ~/.config/codex/mcp-victorops.env
```

---

## 🐛 Troubleshooting

### Issue: `claude-start: command not found`

**Solution:**
```bash
# Check if ~/bin is in PATH
echo $PATH | grep "$HOME/bin"

# If not, add to ~/.zshrc or ~/.bashrc:
export PATH="$HOME/bin:$PATH"

# Reload
source ~/.zshrc
```

### Issue: MCP servers not showing up

**Solution:**
```bash
# Re-register all MCPs
cd ~/AI-Playground/docs/mcp-setup
./register-mcps.sh

# Verify
claude mcp list
```

### Issue: OAuth not working

**Solution:**
```bash
# Check if Codex is available (used as fallback)
which codex

# Manually authenticate via Codex
codex mcp login atlassian

# Or wait for Claude Code to prompt when you use the service
```

### Issue: Terraform/VictorOps env file not found

**Solution:**
```bash
# Create the env file
mkdir -p ~/.config/codex
touch ~/.config/codex/mcp-terraform.env
touch ~/.config/codex/mcp-victorops.env

# Add your tokens
echo "TFC_TOKEN=your-token" >> ~/.config/codex/mcp-terraform.env
```

### Issue: GitHub PAT token not configured

**Solution:**
```bash
# Generate token from gh CLI
export GITHUB_PAT_TOKEN=$(gh auth token)

# Or add to shell config
echo 'export GITHUB_PAT_TOKEN=$(gh auth token 2>/dev/null)' >> ~/.zshrc
source ~/.zshrc
```

### Issue: Permission denied when running scripts

**Solution:**
```bash
# Make scripts executable
chmod +x ~/AI-Playground/tools/*/install.sh
chmod +x ~/AI-Playground/docs/mcp-setup/*.sh
```

---

## 🔄 Updating

### Update Repository

```bash
cd ~/AI-Playground
git pull origin main
```

### Re-run Installation

```bash
# Re-install tools
cd tools/claude-start && ./install.sh
cd tools/codex-start && ./install.sh

# Re-register MCPs if needed
cd docs/mcp-setup && ./register-mcps.sh
```

---

## 🏢 Team Installation

### For Team Admins

1. **Share this guide** with team members
2. **Set up tokens** in a secure location (1Password, etc.)
3. **Create team env file** with shared configuration
4. **Document custom checks** in `.claude-start-custom.sh`

### For Team Members

1. **Follow Quick Install** section
2. **Get tokens** from team admin
3. **Configure environment** with team settings
4. **Test installation** with verification steps

### Team Environment File Example

Create `~/.ai-playground-team.env`:

```bash
# Team-specific configuration
export CODEX_START_AWS_PROFILE="team-prod"
export CODEX_START_KUBE_CONTEXTS="prod-us-west-2 prod-eu-west-1"
export CODEX_START_MCP_OAUTH_SERVERS="atlassian webexapis"
```

Share this file with team members securely.

---

## 📚 Additional Resources

- **Main README**: [README.md](README.md)
- **MCP Setup Guide**: [docs/mcp-setup/INDEX.md](docs/mcp-setup/INDEX.md)
- **OAuth Guide**: [docs/mcp-setup/OAUTH_GUIDE.md](docs/mcp-setup/OAUTH_GUIDE.md)
- **claude-start README**: [tools/claude-start/README.md](tools/claude-start/README.md)
- **codex-start README**: [tools/codex-start/README.md](tools/codex-start/README.md)

---

## 🆘 Support

### Getting Help

1. Check [Troubleshooting](#troubleshooting) section
2. Review [docs/mcp-setup/](docs/mcp-setup/) documentation
3. Run verification scripts:
   ```bash
   ~/AI-Playground/docs/mcp-setup/verify-mcps.sh
   ```
4. Open an issue: https://github.com/juvaraju-hub/AI-Playground/issues

### Common Questions

**Q: Do I need both claude-start and codex-start?**  
A: No, install only what you use:
- Claude Code users → `claude-start`
- Codex users → `codex-start`
- Both → Install both!

**Q: Can I customize the checks?**  
A: Yes! Create `.claude-start-custom.sh` in your project root with custom checks.

**Q: How do I uninstall?**  
A:
```bash
rm ~/bin/claude-start ~/bin/codex-start
rm -rf ~/AI-Playground
# Remove from ~/.zshrc: PATH and aliases
```

**Q: Are the tokens safe?**  
A: Tokens are stored locally in Claude/Codex configs. Never commit them to git.

---

## ✅ Installation Complete!

You're all set! Start using:

```bash
# Claude Code
claude-start
claude-start --refresh-mcp

# Codex
codex-start
codex-start --refresh-mcp
```

For daily usage tips, see [QUICKSTART](docs/mcp-setup/QUICKSTART.txt).

---

**Questions?** Open an issue or check the documentation in `docs/mcp-setup/`
