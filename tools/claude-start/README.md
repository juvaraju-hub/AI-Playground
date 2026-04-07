# Claude Start - Enhanced Preflight Launcher

Reusable Claude Code preflight launcher with comprehensive MCP management and individual OAuth control.

## 🚀 Quick Start

### Installation

```bash
cd tools/claude-start
./install.sh
```

This installs `claude-start` to `~/bin/claude-start` and makes it available in your PATH.

### Basic Usage

```bash
# Normal launch with checks
claude-start

# Check and authenticate OAuth MCPs (individual control)
claude-start --refresh-mcp

# Check status only (no launch)
claude-start --check-only

# Auto-authenticate all (no prompts)
claude-start --refresh-mcp --yes

# Show help
claude-start --help
```

### Optional Alias

Add to `~/.zshrc` or `~/.bashrc`:
```bash
alias ccx='claude-start'
```

## ✨ Features

### Preflight Checks
- ✅ **GitHub CLI** - Validates `gh auth status`
- ✅ **AWS CLI** - Checks `aws sts get-caller-identity`
- ✅ **Kubernetes** - Validates context accessibility
- ✅ **MCP Servers** - Checks all 14 configured MCPs
- ✅ **OAuth Status** - Individual validation per server

### MCP Management (14 Servers)

#### OAuth Servers (5) - Individual Control
- **atlassian** - Jira/Confluence
- **webexapis** - Cisco Webex
- **datadog_us** - Datadog US Region
- **datadog_eu** - Datadog EU Region
- **argocd-sbx** - ArgoCD Sandbox

#### Passive Servers (9)
- **github** - GitHub API
- **context7** - Context management
- **terraform** - Terraform with env file
- **terraform-cloud** - Terraform Cloud
- **victorops** - VictorOps/Splunk On-Call
- **aws-knowledge-mcp-server** - AWS docs
- **openaiDeveloperDocs** - OpenAI docs
- **kubernetes** - K8s management
- **chrome-devtools** - Chrome DevTools

### Individual OAuth Control 🎯

**NEW:** Each OAuth server is asked separately!

```bash
$ claude-start --refresh-mcp

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OAuth MCP Server Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Atlassian (Jira/Confluence) - Connected
  ⚠️  Webex APIs - Needs authentication
  ⚠️  Datadog US Region - Needs authentication
  ⚠️  Datadog EU Region - Needs authentication
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Server: Webex APIs
Status: Needs authentication
Usage: Ask: 'Show my Webex teams'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Authenticate Webex APIs now? (y/N) y
  ✓ OAuth completed for Webex APIs

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Server: Datadog US Region
Status: Needs authentication
Usage: Ask: 'Show my Datadog monitors'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Authenticate Datadog US Region now? (y/N) y
  ✓ OAuth completed for Datadog US Region

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Server: Datadog EU Region
Status: Needs authentication
Usage: Ask: 'Show my Datadog monitors'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Authenticate Datadog EU Region now? (y/N) n
  ⊘ Skipping Datadog EU Region - will authenticate when used in Claude

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OAuth Authentication Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Already connected:     1 server(s)
  ✓ Authenticated now:     2 server(s)
  ⊘ Skipped (for later):   1 server(s)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Key Benefits:**
- 🎯 **Granular Control** - Choose which servers to auth now vs later
- 🌍 **Regional Control** - Datadog US and EU handled separately
- 📝 **Clear Status** - Friendly names and usage examples
- 📊 **Detailed Summary** - Know exactly what happened

## 📖 Documentation

Complete MCP setup documentation: **[docs/mcp-setup/INDEX.md](../../docs/mcp-setup/INDEX.md)**

- [SETUP_COMPLETE.md](../../docs/mcp-setup/SETUP_COMPLETE.md) - Full setup guide
- [OAUTH_GUIDE.md](../../docs/mcp-setup/OAUTH_GUIDE.md) - OAuth authentication
- [UPDATE_INDIVIDUAL_CONTROL.md](../../docs/mcp-setup/UPDATE_INDIVIDUAL_CONTROL.md) - Individual control feature
- [QUICKSTART.txt](../../docs/mcp-setup/QUICKSTART.txt) - Quick reference

## 🎯 Use Cases

### Scenario 1: Daily Launch
```bash
# Quick launch with standard checks
claude-start

# Or with alias
ccx
```

### Scenario 2: Selective OAuth
```bash
# Only authenticate Datadog US today
claude-start --refresh-mcp

# When prompted:
# Authenticate Datadog US? → y (yes, authenticate now)
# Authenticate Datadog EU? → n (skip for later)
```

### Scenario 3: Full Setup
```bash
# Authenticate all servers without prompts
claude-start --refresh-mcp --yes
```

### Scenario 4: Status Check
```bash
# Check everything without launching
claude-start --check-only --refresh-mcp
```

## ⚙️ Configuration

### Environment Variables

```bash
# AWS profile to check
export CODEX_START_AWS_PROFILE="my-profile"

# OAuth MCP servers (each asked individually)
export CODEX_START_MCP_OAUTH_SERVERS="atlassian webexapis datadog_us datadog_eu argocd-sbx"

# Passive MCP servers
export CODEX_START_MCP_PASSIVE_SERVERS="github context7 terraform terraform-cloud victorops aws-knowledge-mcp-server openaiDeveloperDocs kubernetes chrome-devtools"

# Auto-refresh MCPs on every run
export CODEX_START_REFRESH_MCP=1

# Kubernetes contexts to validate
export CODEX_START_KUBE_CONTEXTS="prod-cluster staging-cluster"

# Open AWS console after auth
export CODEX_START_OPEN_AWS_CONSOLE=1

# Use AWS Bedrock
export CODEX_START_USE_BEDROCK=1
```

### Adding Custom Checks

Create `.claude-start-custom.sh` in your project:

```bash
#!/bin/bash
# Custom preflight checks for your project

echo "🔍 Custom Checks"

# Check local services
if ! curl -sf http://localhost:3000/health &> /dev/null; then
  echo "⚠️  API not running: npm run dev"
fi

# Check database
if ! pg_isready -h localhost &> /dev/null; then
  echo "⚠️  PostgreSQL not running: docker-compose up -d"
fi
```

## 🔄 Comparison with Codex

| Feature | Codex Start | Claude Start |
|---------|-------------|--------------|
| GitHub check | ✓ | ✓ |
| AWS check | ✓ | ✓ |
| Kubernetes check | ✓ | ✓ |
| MCP servers | 14 | 14 |
| OAuth prompt | All-or-nothing | Individual |
| Datadog regions | Together | Separate |
| Friendly names | No | Yes |
| Usage examples | No | Yes |
| Summary detail | Basic | Detailed |

## 🛠️ Troubleshooting

### MCPs not showing up
```bash
# Check registration
claude mcp list

# Re-register all
~/docs/mcp-setup/register-mcps.sh
```

### OAuth not working
```bash
# Check if Codex is available (used as fallback)
which codex

# Manually authenticate via Codex
codex mcp login atlassian

# Then try claude-start again
claude-start --refresh-mcp
```

### Environment variables not loading
```bash
# Source the startup script
source ~/.config/claude-code/startup.sh

# Or add to shell config
echo 'source ~/.config/claude-code/startup.sh' >> ~/.zshrc
```

## 📝 Command Reference

```bash
# Launch
claude-start                           # Run checks and launch
claude-start --check-only              # Check without launching
claude-start --no-launch               # Check but don't launch

# OAuth
claude-start --refresh-mcp             # Individual OAuth control
claude-start --refresh-mcp --yes       # Auto-authenticate all
claude-start --setup-mcp               # Same as --refresh-mcp

# Other
claude-start --open-aws-console        # Open AWS console after auth
claude-start --help                    # Show help
```

## 🎉 Migrating from Codex

If you're coming from `codex-start`:

1. **Install:** `./install.sh`
2. **Register MCPs:** Run the registration scripts in `docs/mcp-setup/`
3. **Update alias:** Change `cx` to `ccx` (or keep both!)
4. **Try individual control:** `claude-start --refresh-mcp`

All your Codex MCP configurations are preserved and work with Claude Code!

## 📞 Support

- Check [docs/mcp-setup/INDEX.md](../../docs/mcp-setup/INDEX.md) for detailed documentation
- Run verification: `~/docs/mcp-setup/verify-mcps.sh`
- See demo: `~/docs/mcp-setup/DEMO_OAUTH.sh`

---

**Built for Claude Code with individual OAuth control** 🚀
