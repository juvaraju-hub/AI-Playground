# Claude Code MCP Setup Documentation

Complete documentation for setting up Claude Code with 14 MCP servers migrated from Codex, featuring automatic OAuth authentication with individual server control.

## 📚 Documentation Index

### Quick Start
- **[QUICKSTART.txt](QUICKSTART.txt)** - Quick reference card (terminal-friendly)
- **[SETUP_COMPLETE.md](SETUP_COMPLETE.md)** - Complete setup guide

### OAuth Authentication
- **[OAUTH_GUIDE.md](OAUTH_GUIDE.md)** - OAuth authentication details
- **[UPDATE_INDIVIDUAL_CONTROL.md](UPDATE_INDIVIDUAL_CONTROL.md)** - Individual OAuth control feature
- **[DEMO_OAUTH.sh](DEMO_OAUTH.sh)** - Interactive OAuth demo

### Configuration Details
- **[README.md](README.md)** - Configuration overview (original)
- **[FINAL_SUMMARY.md](FINAL_SUMMARY.md)** - Complete summary of the setup

### Helper Scripts
- **[register-mcps.sh](register-mcps.sh)** - Register all 14 MCP servers
- **[verify-mcps.sh](verify-mcps.sh)** - Verify MCP configuration
- **[TEST_OAUTH.sh](TEST_OAUTH.sh)** - Test OAuth validation
- **[startup.sh](startup.sh)** - Environment setup

## 🚀 Quick Start

### 1. Install claude-start
```bash
cd tools/claude-start
./install.sh
```

### 2. Register MCPs
```bash
~/docs/mcp-setup/register-mcps.sh
```

### 3. Verify Setup
```bash
claude-start --check-only
```

### 4. Authenticate OAuth MCPs (Individual Control)
```bash
claude-start --refresh-mcp

# You'll be asked for EACH server:
# - Authenticate Atlassian now? (y/N)
# - Authenticate Webex now? (y/N)
# - Authenticate Datadog US now? (y/N)
# - Authenticate Datadog EU now? (y/N)
# - etc.
```

## ✅ What's Included

### 14 MCP Servers
- **8 HTTP/Remote:** atlassian, webexapis, argocd-sbx, github, datadog_us, datadog_eu, aws-knowledge-mcp-server, openaiDeveloperDocs
- **3 NPX:** chrome-devtools, kubernetes, context7
- **3 UV:** terraform-cloud, terraform, victorops

### Features
- ✅ All 14 MCP servers registered
- ✅ Automatic OAuth authentication
- ✅ Individual server control (choose which to auth)
- ✅ Datadog US and EU handled separately
- ✅ Enhanced preflight checks
- ✅ Browser-based OAuth flows

## 📖 Documentation Guide

### For First-Time Setup
1. Read [SETUP_COMPLETE.md](SETUP_COMPLETE.md)
2. Run the helper scripts
3. Test with [TEST_OAUTH.sh](TEST_OAUTH.sh)

### For OAuth Authentication
1. Read [OAUTH_GUIDE.md](OAUTH_GUIDE.md)
2. See [UPDATE_INDIVIDUAL_CONTROL.md](UPDATE_INDIVIDUAL_CONTROL.md) for individual control
3. Try the demo: [DEMO_OAUTH.sh](DEMO_OAUTH.sh)

### For Daily Use
1. Keep [QUICKSTART.txt](QUICKSTART.txt) handy
2. Use `claude-start --help` for options
3. Run `claude-start --refresh-mcp` as needed

## 🔐 OAuth Individual Control

NEW FEATURE: Each OAuth MCP server is asked individually!

```bash
$ claude-start --refresh-mcp

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Server: Datadog US Region
Status: Needs authentication
Usage: Ask: 'Show my Datadog monitors'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Authenticate Datadog US Region now? (y/N) y
  ✓ OAuth completed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Server: Datadog EU Region
Status: Needs authentication
Usage: Ask: 'Show my Datadog monitors'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Authenticate Datadog EU Region now? (y/N) n
  ⊘ Skipping - will authenticate when used in Claude
```

**You control which servers to authenticate now vs later!**

## 🎯 Use Cases

### Scenario 1: Full Setup
```bash
# Register all servers
docs/mcp-setup/register-mcps.sh

# Authenticate all OAuth servers
claude-start --refresh-mcp --yes

# Launch Claude
claude-start
```

### Scenario 2: Selective Authentication
```bash
# Only authenticate Datadog US today
claude-start --refresh-mcp
# Answer 'y' only for Datadog US, 'n' for others
```

### Scenario 3: Check Status
```bash
# See what needs authentication
claude-start --check-only --refresh-mcp
```

## 📁 File Structure

```
AI-Playground/
├── docs/
│   └── mcp-setup/
│       ├── INDEX.md (this file)
│       ├── SETUP_COMPLETE.md
│       ├── OAUTH_GUIDE.md
│       ├── UPDATE_INDIVIDUAL_CONTROL.md
│       ├── FINAL_SUMMARY.md
│       ├── QUICKSTART.txt
│       ├── README.md
│       ├── register-mcps.sh
│       ├── verify-mcps.sh
│       ├── TEST_OAUTH.sh
│       ├── DEMO_OAUTH.sh
│       └── startup.sh
└── tools/
    └── claude-start/
        ├── claude-start (main script)
        └── install.sh
```

## 🔗 Related

- **claude-start tool:** `tools/claude-start/`
- **Codex setup:** `tools/codex-start/`
- **Claude skills:** `.claude/skills/`

## 💡 Tips

1. **Run `--refresh-mcp` periodically** to keep OAuth tokens fresh
2. **Use `--check-only`** to see status without launching
3. **Datadog US and EU** are separate - authenticate independently
4. **Skipped servers** will prompt when you use them in Claude
5. **Use `--yes`** to auto-authenticate all servers without prompts

## 🆘 Troubleshooting

### MCP server not showing up
```bash
# Re-register
claude mcp remove <server-name> -s user
docs/mcp-setup/register-mcps.sh
```

### OAuth not working
```bash
# Check status
claude-start --check-only --refresh-mcp

# Manually authenticate via Codex (if available)
codex mcp login <server-name>
```

### Environment variables not loading
```bash
# Check if startup script is sourced
grep "claude-code/startup.sh" ~/.zshrc

# Source manually
source ~/.config/claude-code/startup.sh
```

## 📞 Support

For issues or questions:
1. Check [SETUP_COMPLETE.md](SETUP_COMPLETE.md) for detailed troubleshooting
2. Review [OAUTH_GUIDE.md](OAUTH_GUIDE.md) for OAuth-specific issues
3. Run verification: `docs/mcp-setup/verify-mcps.sh`

---

**Last Updated:** April 2026  
**Status:** ✅ All 14 MCP servers configured with individual OAuth control
