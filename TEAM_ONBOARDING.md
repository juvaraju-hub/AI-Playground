# Team Onboarding Guide

Quick reference for onboarding new team members to AI-Playground.

## 📧 Message to Send to New Team Members

```
Hi [Name]! 👋

Welcome to the team! We use AI-Playground for our development tools and Claude Code/Codex setup.

Getting started takes about 5 minutes:

🚀 Quick Install:

1. Check what you have (optional):
   curl -fsSL https://raw.githubusercontent.com/juvaraju-hub/AI-Playground/main/scripts/check-prerequisites.sh | bash

2. Install everything:
   curl -fsSL https://raw.githubusercontent.com/juvaraju-hub/AI-Playground/main/scripts/install.sh | bash

3. Reload your shell:
   source ~/.zshrc  # or ~/.bashrc

4. Verify it works:
   claude-start --check-only

5. Set up OAuth (Claude Code only):
   claude-start --refresh-mcp

That's it! ✅

📚 Documentation:
- Quick Start: https://github.com/juvaraju-hub/AI-Playground/blob/main/QUICKSTART.md
- Full Guide: https://github.com/juvaraju-hub/AI-Playground/blob/main/INSTALL.md
- MCP Setup: https://github.com/juvaraju-hub/AI-Playground/blob/main/docs/mcp-setup/INDEX.md

Questions? Ping me or check the troubleshooting section!
```

## 🎯 What They'll Get

### Tools
- **claude-start** - Preflight launcher for Claude Code
- **codex-start** - Preflight launcher for Codex
- Aliases: `ccx`, `cx` (optional)

### MCP Servers (14 total)
- **OAuth (5):** atlassian, webexapis, datadog_us, datadog_eu, argocd-sbx
- **Passive (9):** github, context7, terraform, terraform-cloud, victorops, aws-knowledge, openaiDeveloperDocs, kubernetes, chrome-devtools

### Documentation
- Complete installation guides
- Troubleshooting
- Daily usage examples
- MCP OAuth guides

## 📋 Prerequisites They Need

### Required
- Claude Code OR Codex (at least one)
- Git
- bash or zsh shell

### Optional but Recommended
- GitHub CLI (`gh`) - For GitHub MCP auth
- AWS CLI - For cloud checks
- kubectl - For Kubernetes checks
- uv - For Python MCP servers
- npx/npm - For NPX MCP servers

### Prerequisites Checker
They can run this to see what's missing:
```bash
curl -fsSL https://raw.githubusercontent.com/juvaraju-hub/AI-Playground/main/scripts/check-prerequisites.sh | bash
```

## 🔐 Tokens/Credentials Setup

Some MCPs require tokens. Here's what you need to share:

### GitHub PAT Token
```bash
# They can generate from gh CLI
export GITHUB_PAT_TOKEN=$(gh auth token)

# Or add to shell config
echo 'export GITHUB_PAT_TOKEN=$(gh auth token 2>/dev/null)' >> ~/.zshrc
```

### Terraform Cloud Token
```bash
# Set environment variable
export TFC_TOKEN="[get from team admin]"

# Or create env file
echo "TFC_TOKEN=[token]" > ~/.config/codex/mcp-terraform.env
```

### VictorOps Token
```bash
# Create env file
mkdir -p ~/.config/codex
echo "VICTOROPS_API_ID=[id]" > ~/.config/codex/mcp-victorops.env
echo "VICTOROPS_API_KEY=[key]" >> ~/.config/codex/mcp-victorops.env
```

## ✅ Verification Checklist

Send this to new members after installation:

```
Installation Verification:

[ ] Tools installed
    which claude-start
    which codex-start

[ ] Aliases work (if added)
    ccx --help
    cx --help

[ ] MCPs registered (Claude Code)
    claude mcp list
    # Should show 14 servers

[ ] OAuth works
    claude-start --refresh-mcp
    # Should prompt for each OAuth server

[ ] Preflight checks pass
    claude-start --check-only
    # Should show green checks

[ ] Can launch
    ccx  # or cx for Codex
    # Should launch successfully
```

## 🐛 Common Issues & Solutions

### "command not found"
**Problem:** `~/bin` not in PATH  
**Solution:**
```bash
export PATH="$HOME/bin:$PATH"
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### MCPs not showing up
**Problem:** MCPs not registered  
**Solution:**
```bash
cd ~/ai-playground/docs/mcp-setup
./register-mcps.sh
```

### OAuth not working
**Problem:** Missing Codex for OAuth fallback  
**Solution:**
- Codex users: `codex mcp login atlassian`
- Claude Code only: Wait for Claude to prompt when using service

### Missing tokens
**Problem:** TFC_TOKEN or other tokens not set  
**Solution:** Share tokens securely via 1Password/team password manager

## 📅 Onboarding Checklist (For Admins)

When onboarding a new team member:

- [ ] Share installation message (above)
- [ ] Provide required tokens securely
- [ ] Share team environment config (if any)
- [ ] Point to team-specific documentation
- [ ] Schedule 15-min setup call if needed
- [ ] Verify installation completed
- [ ] Add to team channel for support

## 🔄 Updating Installation

To update existing installations:

```bash
cd ~/ai-playground  # or wherever installed
git pull origin main

# Re-install tools
cd tools/claude-start && ./install.sh
cd tools/codex-start && ./install.sh

# Re-register MCPs if needed
cd docs/mcp-setup && ./register-mcps.sh
```

## 💡 Pro Tips for Team

### Daily Usage
```bash
# Morning routine
ccx --refresh-mcp  # or cx
```

### Quick Checks
```bash
ccx-check  # Just check status, don't launch
cx-check
```

### OAuth Refresh
```bash
ccx-mcp  # Refresh OAuth tokens
cx-mcp
```

### In Claude/Codex
```bash
/claude-start --refresh-mcp
/codex-start --refresh-mcp
```

## 📞 Support Resources

**Documentation:**
- [Quick Start](QUICKSTART.md)
- [Installation Guide](INSTALL.md)
- [MCP Setup](docs/mcp-setup/INDEX.md)
- [OAuth Guide](docs/mcp-setup/OAUTH_GUIDE.md)

**Repository:**
- https://github.com/juvaraju-hub/AI-Playground

**Issues:**
- https://github.com/juvaraju-hub/AI-Playground/issues

## 🎯 Success Metrics

A successful onboarding means the new member can:

✅ Run `claude-start` or `codex-start` successfully  
✅ See all 14 MCP servers configured  
✅ Authenticate OAuth servers individually  
✅ Use preflight checks before launching  
✅ Find and use documentation  

**Typical time:** 5-10 minutes for installation + setup

---

## 📊 Team Statistics

Track these to measure adoption:

- Number of team members with tools installed
- Common issues encountered
- Time to complete installation
- MCP servers most commonly used
- Documentation most frequently accessed

Use this to improve the onboarding process over time!

---

**Questions about onboarding?** Update this guide or open an issue!
