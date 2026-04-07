# Claude Code MCP Setup - Complete! 🎉

## Summary

All 14 MCP servers from your Codex configuration have been migrated to Claude Code.

## ✅ Status: 14/14 Servers Registered

### 🟢 Connected (9 servers)
These are working and ready to use:
- ✓ **atlassian** - Jira/Confluence integration
- ✓ **webexapis** - Cisco Webex APIs
- ✓ **aws-knowledge-mcp-server** - AWS documentation
- ✓ **openaiDeveloperDocs** - OpenAI developer docs
- ✓ **chrome-devtools** - Chrome DevTools protocol
- ✓ **context7** - Context management
- ✓ **terraform** - Terraform with env file
- ✓ **victorops** - VictorOps/Splunk On-Call
- ✓ **kubernetes** - Kubernetes cluster management

### 🟡 Needs Authentication (2 servers)
These require OAuth authentication when first used:
- ! **datadog_us** - Datadog US region
- ! **datadog_eu** - Datadog EU region

**To authenticate:** Ask Claude to use these services (e.g., "Show my Datadog monitors"), and it will trigger OAuth in your browser.

### 🔴 Failed to Connect (3 servers)
These need additional configuration:
- ✗ **argocd-sbx** - May need network access or authentication
- ✗ **github** - Needs GITHUB_PAT_TOKEN environment variable
- ✗ **terraform-cloud** - Token configuration issue

## 🔧 Fixes Needed

### 1. Fix GitHub MCP
```bash
# Set GitHub token (option 1: export in shell)
export GITHUB_PAT_TOKEN=$(gh auth token)

# Or (option 2: add to ~/.zshrc)
echo 'export GITHUB_PAT_TOKEN=$(gh auth token 2>/dev/null || echo "")' >> ~/.zshrc
source ~/.zshrc
```

### 2. Fix Terraform Cloud MCP
The token is in the server configuration but may not be picked up. Try:
```bash
# Re-register with explicit token
claude mcp remove terraform-cloud -s user
claude mcp add -e TFC_TOKEN=YOUR_TOKEN_HERE --scope user terraform-cloud -- uv run terraform-cloud-mcp
```

### 3. Fix ArgoCD (if needed)
Check if the service is accessible:
```bash
curl -I https://mcp-argocd-sbx.aiteam.cisco.com/mcp
```

## 📋 Files Created

1. **`~/.claude.json`** - Main Claude Code configuration (auto-managed)
2. **`~/.claude/settings.json`** - User settings with MCP enablement
3. **`~/bin/claude-start`** - Updated preflight script (checks all 14 servers)
4. **`~/.config/claude-code/register-mcps.sh`** - Registration script (for re-setup)
5. **`~/.config/claude-code/verify-mcps.sh`** - Verification script
6. **`~/.config/claude-code/startup.sh`** - Environment setup script

## 🚀 Quick Start

### Start Claude Code
```bash
# Option 1: Use the alias
ccx

# Option 2: Use claude-start directly
claude-start

# Option 3: Direct launch
claude
```

### Your Preflight Script
The `claude-start` script now checks all 14 MCP servers with **automatic OAuth authentication**:

```bash
# Normal launch with checks
claude-start

# Check status only (no launch)
claude-start --check-only

# Check + authenticate OAuth MCPs (opens browser automatically!)
claude-start --refresh-mcp

# Same, without prompts
claude-start --refresh-mcp --yes

# Test OAuth validation without launching
~/.config/claude-code/TEST_OAUTH.sh
```

**New Feature:** `--refresh-mcp` now automatically opens your browser for OAuth authentication, just like Codex! No manual steps needed.

## 🔍 Verify Configuration

Run the verification script:
```bash
~/.config/claude-code/verify-mcps.sh
```

Or check MCP status manually:
```bash
claude mcp list
```

## 📚 Using MCP Servers

Once Claude Code is running, you can use any connected MCP server:

```text
# Examples:
"Search my Jira issues for login bugs"
"Show my Webex teams"
"Get AWS documentation about S3"
"Query Kubernetes pods in production"
"Show my Datadog monitors" (will trigger OAuth in browser if needed)
```

## 🔐 OAuth Authentication

Your `claude-start` script now handles OAuth automatically:

### Automatic Authentication
```bash
# Check and authenticate all OAuth MCPs
claude-start --refresh-mcp
```

**What happens:**
1. Checks status of all OAuth MCP servers
2. Detects which ones need authentication
3. Opens browser automatically for OAuth (via Codex)
4. Completes authentication
5. Launches Claude Code

### OAuth Servers
- **atlassian** - Jira/Confluence
- **webexapis** - Cisco Webex  
- **datadog_us** - Datadog US
- **datadog_eu** - Datadog EU

See the [OAuth Guide](OAUTH_GUIDE.md) for detailed information.

## 🔄 Differences from Codex

| Aspect | Codex | Claude Code |
|--------|-------|-------------|
| Config | `~/.codex/config.toml` | `~/.claude.json` |
| Registration | TOML-based | `claude mcp add` command |
| OAuth | `codex mcp login` | Browser-based OAuth flow |
| Health check | `codex mcp get` | `claude mcp list` |

## 🛠️ Troubleshooting

### MCP server not showing up
```bash
# Re-register
claude mcp remove <name> -s user
~/.config/claude-code/register-mcps.sh
```

### OAuth not working
```bash
# Use --refresh-mcp flag
claude-start --refresh-mcp
# Or authenticate manually via Codex first
codex mcp login atlassian
```

### Environment variables not loading
```bash
# Check if startup script is sourced
grep "claude-code/startup.sh" ~/.zshrc

# Source manually
source ~/.config/claude-code/startup.sh
```

## 📝 Environment Variables

These are set automatically by `claude-start`:
- `GITHUB_PAT_TOKEN` - From gh CLI
- `KUBECONFIG` - ~/.kube/config
- `CLAUDE_CODE_USE_BEDROCK` - AWS Bedrock (default: 1)

## 🎯 Next Steps

1. ✅ **Complete** - All 14 MCP servers registered
2. ✅ **Complete** - Updated claude-start script
3. 🔄 **Optional** - Fix GitHub MCP (add GITHUB_PAT_TOKEN)
4. 🔄 **Optional** - Fix terraform-cloud MCP
5. 🔄 **Optional** - Test Datadog OAuth when needed

## 📞 Getting Help

- Check status: `claude mcp list`
- View server details: `claude mcp get <name>`
- Remove server: `claude mcp remove <name> -s user`
- Re-register all: `~/.config/claude-code/register-mcps.sh`

## 🎉 Success!

Your Claude Code environment is now configured with all 14 MCP servers from Codex!

Run `claude-start` or `ccx` to begin using Claude Code with your full MCP setup.
