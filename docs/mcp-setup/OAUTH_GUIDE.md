# MCP OAuth Authentication Guide

## 🔐 OAuth Flow with claude-start

Your `claude-start` script now automatically handles MCP OAuth authentication, just like Codex!

## Quick Start

### Check and Authenticate MCPs (Individual Control)
```bash
# Check status and ask for each server individually
claude-start --refresh-mcp

# Auto-authenticate all (no prompts)
claude-start --refresh-mcp --yes

# Check status only (no authentication)
claude-start --check-only --refresh-mcp
```

### What Happens:
1. **Checks all MCP servers** - Queries `claude mcp list` for status
2. **Shows each OAuth server separately** - Displays friendly name, status, and usage example
3. **Asks individually** - "Authenticate [Server Name] now? (y/N)"
4. **You control each** - Authenticate now or skip for later
5. **Triggers OAuth flow** - Opens browser automatically for servers you approve (via Codex)
6. **Shows summary** - Connected, authenticated, and skipped counts

## Example Session (Individual Control)

```bash
$ claude-start --refresh-mcp

[claude-start] Running preflight checks...
[claude-start] ✓ GitHub authenticated
[claude-start] ✓ AWS authenticated
[claude-start] ✓ Kubernetes context accessible
[claude-start] Checking OAuth MCP services...

[claude-start] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[claude-start] OAuth MCP Server Status
[claude-start] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[claude-start]   ✓ Atlassian (Jira/Confluence) - Connected
[claude-start]   ✓ Webex APIs - Connected
[claude-start]   ⚠️  Datadog US Region - Needs authentication
[claude-start]   ⚠️  Datadog EU Region - Needs authentication
[claude-start]   ⊘ ArgoCD Sandbox - Not configured
[claude-start] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[claude-start] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[claude-start] Server: Datadog US Region
[claude-start] Status: Needs authentication
[claude-start] Usage: Ask: 'Show my Datadog monitors'
[claude-start] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[claude-start] Authenticate Datadog US Region now? (y/N) y
[claude-start] Triggering OAuth for: Datadog US Region
[claude-start]   → Opening browser for authentication...
[claude-start]   → Using Codex to initiate OAuth flow
[claude-start]   ✓ OAuth completed for Datadog US Region

[claude-start] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[claude-start] Server: Datadog EU Region
[claude-start] Status: Needs authentication
[claude-start] Usage: Ask: 'Show my Datadog monitors'
[claude-start] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[claude-start] Authenticate Datadog EU Region now? (y/N) n
[claude-start] ⊘ Skipping Datadog EU Region - will authenticate when used in Claude

[claude-start] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[claude-start] OAuth Authentication Summary
[claude-start] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[claude-start]   ✓ Already connected:     2 server(s)
[claude-start]   ✓ Authenticated now:     1 server(s)
[claude-start]   ⊘ Skipped (for later):   1 server(s)
[claude-start] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[claude-start] ℹ️  Skipped servers will prompt for authentication when you
[claude-start]   ask Claude to use them (browser opens automatically)

[claude-start] Launching Claude Code...
```

## MCP Server Status

The script checks these OAuth servers by default (each asked individually):
- **atlassian** → Atlassian (Jira/Confluence)
- **webexapis** → Webex APIs
- **datadog_us** → Datadog US Region
- **datadog_eu** → Datadog EU Region
- **argocd-sbx** → ArgoCD Sandbox

### Status Indicators:
- **✓ Connected** - Ready to use, skipped in prompts
- **⚠️ Needs authentication** - Will ask if you want to authenticate now
- **⊘ Not configured** - Server not registered yet
- **? Status unknown** - Unable to determine status

## OAuth Flow Details

### How It Works:
1. **Codex Fallback** - Uses `codex mcp login <server>` to initiate OAuth
   - Opens browser automatically
   - Completes OAuth flow
   - Tokens are shared between Codex and Claude Code (for same servers)

2. **Manual Fallback** - If Codex not available:
   - Shows instructions to use service in Claude
   - Claude will trigger OAuth when you use the MCP
   - Example: "Search my Jira issues" → Opens browser

3. **Browser Authentication**:
   - Browser opens automatically
   - Login to the service (if not already logged in)
   - Authorize Claude Code
   - Browser returns to Claude Code
   - Token saved automatically

## Environment Variables

Configure which servers to check:

```bash
# OAuth servers (trigger browser auth)
export CODEX_START_MCP_OAUTH_SERVERS="atlassian webexapis datadog_us datadog_eu"

# Passive servers (no OAuth needed)
export CODEX_START_MCP_PASSIVE_SERVERS="github context7 terraform terraform-cloud victorops aws-knowledge-mcp-server openaiDeveloperDocs kubernetes chrome-devtools argocd-sbx"
```

## Common Workflows

### Initial Setup
```bash
# First time: Register all MCPs and authenticate
~/.config/claude-code/register-mcps.sh
claude-start --refresh-mcp --yes
```

### Daily Use
```bash
# Normal launch with checks
claude-start

# Or use the alias
ccx
```

### Re-authenticate a Server
```bash
# Check status first
claude-start --check-only

# Trigger OAuth if needed
claude-start --refresh-mcp
```

### Troubleshooting
```bash
# Check what's wrong
claude-start --check-only

# Force re-authentication
codex mcp login atlassian

# Or via Claude Code
claude mcp list  # See which servers need auth
# Then use the service in Claude to trigger OAuth
```

## Comparison: Codex vs Claude Code

| Feature | Codex | Claude Code (claude-start) |
|---------|-------|----------------------------|
| OAuth trigger | `codex mcp login <server>` | `claude-start --refresh-mcp` |
| Browser opens | ✓ Automatic | ✓ Automatic (via Codex) |
| Token sharing | Per-service | Shared with Codex |
| Validation | Built-in | Via `claude mcp list` |
| Manual fallback | N/A | Use service in Claude |

## Tips

1. **Run --refresh-mcp periodically** to keep tokens fresh
2. **Use --check-only** to see status without launching
3. **OAuth tokens expire** - re-run --refresh-mcp when needed
4. **Codex and Claude Code share tokens** for the same services
5. **Some services may still require** using the service in Claude once after Codex auth

## Security

- OAuth tokens are stored securely by Claude Code
- Tokens are service-specific (not shared across services)
- Browser authentication uses secure OAuth 2.0 flows
- Tokens can be revoked via the service's settings

## Need Help?

```bash
# Check server status
claude mcp list

# View server details
claude mcp get <server-name>

# Remove and re-add a server
claude mcp remove <server-name> -s user
~/.config/claude-code/register-mcps.sh

# Full documentation
cat ~/.config/claude-code/SETUP_COMPLETE.md
```
