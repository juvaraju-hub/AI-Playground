# Claude Code MCP Configuration

## Overview
This configuration migrates your MCP servers from Codex to Claude Code.

## Files Created

### 1. `~/.mcp.json` (User-level MCP configuration)
Main MCP server configuration file with all 14 servers:
- **Remote servers** (URL-based): atlassian, webexapis, argocd-sbx, github, datadog_us, datadog_eu, aws-knowledge-mcp-server, openaiDeveloperDocs
- **NPX servers**: chrome-devtools, kubernetes, context7
- **UV servers**: terraform-cloud, terraform, victorops

### 2. `~/.claude/settings.json`
Claude Code user settings:
- Enables all project MCP servers
- Sets up environment variables

### 3. `~/.config/claude-code/startup.sh`
Startup script that:
- Exports required environment variables
- Sets up GITHUB_PAT_TOKEN
- Configures KUBECONFIG

### 4. `~/bin/claude-start` (updated)
Updated to check all 14 MCP servers during preflight:
- OAuth servers: atlassian, webexapis, datadog_us, datadog_eu
- Passive servers: github, context7, terraform, terraform-cloud, victorops, aws-knowledge, openaiDeveloperDocs, kubernetes, chrome-devtools, argocd-sbx

### 5. `~/.zshrc` (modified)
Added source command to load startup script automatically

## Environment Variables Required

Make sure these are set in your shell or keychain:

```bash
# GitHub Personal Access Token (for github MCP)
export GITHUB_PAT_TOKEN="your_token_here"

# Kubernetes config (already in Codex config)
export KUBECONFIG="/home/juvaraju/.kube/config"
```

## Terraform Cloud Token
The TFC_TOKEN is embedded in the mcp.json file:
- **Location**: `~/.config/claude-code/mcp.json`
- **Server**: terraform-cloud
- **Note**: Consider moving to environment variable for better security

## How to Use

### Option 1: Start new shell
```bash
# Open a new terminal - startup.sh will run automatically
claude
```

### Option 2: Source manually
```bash
source ~/.config/claude-code/startup.sh
claude
```

### Option 3: Reload zsh config
```bash
source ~/.zshrc
claude
```

## Verify Configuration

Check if MCP servers are loaded:
```bash
# In Claude Code, you can check available MCP tools
# The tools from all 14 servers should be available
```

## Differences from Codex

| Aspect | Codex | Claude Code |
|--------|-------|-------------|
| Config file | `~/.codex/config.toml` | `~/.config/claude-code/mcp.json` |
| Format | TOML | JSON |
| Settings | `config.toml` | `~/.claude/settings.json` |
| Auto-enable | `experimental_use_rmcp_client = true` | `enableAllProjectMcpServers: true` |

## MCP Server Details

### Remote Servers (8)
1. **atlassian** - Jira/Confluence integration
2. **webexapis** - Cisco Webex APIs
3. **argocd-sbx** - ArgoCD sandbox
4. **github** - GitHub integration (requires GITHUB_PAT_TOKEN)
5. **datadog_us** - Datadog US region
6. **datadog_eu** - Datadog EU region
7. **aws-knowledge-mcp-server** - AWS documentation
8. **openaiDeveloperDocs** - OpenAI docs

### NPX Servers (3)
1. **chrome-devtools** - Chrome DevTools protocol
2. **kubernetes** - Kubernetes cluster management
3. **context7** - Context management

### UV Servers (3)
1. **terraform-cloud** - Terraform Cloud API
2. **terraform** - Terraform with custom env file
3. **victorops** - VictorOps/Splunk On-Call

## Troubleshooting

### MCP servers not available
1. Check if mcp.json exists: `cat ~/.config/claude-code/mcp.json`
2. Verify settings.json: `cat ~/.claude/settings.json`
3. Check environment variables: `echo $GITHUB_PAT_TOKEN`

### GitHub MCP not working
Ensure GITHUB_PAT_TOKEN is set:
```bash
export GITHUB_PAT_TOKEN="ghp_xxxxxxxxxxxx"
```

Or store in macOS keychain:
```bash
security add-generic-password -a "$USER" -s github_pat -w "ghp_xxxxxxxxxxxx"
```

### Kubernetes MCP issues
Verify KUBECONFIG path:
```bash
ls -la /home/juvaraju/.kube/config
# Note: Update path to /Users/juvaraju/.kube/config if needed
```

## Security Notes

⚠️ **Sensitive Data**
- TFC_TOKEN is stored in plaintext in mcp.json
- Consider using environment variables or keychain for tokens
- Never commit mcp.json to version control if it contains secrets

## Next Steps

1. ✅ Configuration files created
2. ✅ Startup script configured
3. ⏭️ Set GITHUB_PAT_TOKEN environment variable
4. ⏭️ Test MCP servers: `claude`
5. ⏭️ Consider moving secrets to environment variables

## Updating Configuration

To add/modify MCP servers, edit:
```bash
~/.config/claude-code/mcp.json
```

Then restart your shell or run:
```bash
source ~/.zshrc
```
