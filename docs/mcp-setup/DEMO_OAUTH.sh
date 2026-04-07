#!/bin/bash
# Demo: Individual OAuth MCP Control

cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║         OAuth MCP Authentication - Individual Control          ║
╚════════════════════════════════════════════════════════════════╝

This demo shows how claude-start gives you control over which
OAuth MCP servers to authenticate.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Example Flow:

1. Check OAuth servers status
   $ claude-start --check-only --refresh-mcp

2. You'll see each OAuth server individually:
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Server: Atlassian (Jira/Confluence)
   Status: Needs authentication
   Usage: Ask: 'Search my Jira issues'
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Authenticate Atlassian (Jira/Confluence) now? (y/N) y

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Server: Webex APIs
   Status: Connected
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   (skipped - already connected)

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Server: Datadog US Region
   Status: Needs authentication
   Usage: Ask: 'Show my Datadog monitors'
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Authenticate Datadog US Region now? (y/N) y

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Server: Datadog EU Region
   Status: Needs authentication
   Usage: Ask: 'Show my Datadog monitors'
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Authenticate Datadog EU Region now? (y/N) n
   ⊘ Skipping - will authenticate when used in Claude

3. Final summary:
   ✓ Already connected:     1 server(s)
   ✓ Authenticated now:     2 server(s)
   ⊘ Skipped (for later):   1 server(s)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Key Features:

✓ Separate prompts for each OAuth MCP server
✓ Datadog US and EU are handled independently
✓ You control when to authenticate each server
✓ Skip servers you don't need right now
✓ Skipped servers authenticate automatically when used in Claude

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Usage:

# Interactive (ask for each server)
claude-start --refresh-mcp

# Auto-authenticate all (no prompts)
claude-start --refresh-mcp --yes

# Check status only
claude-start --check-only --refresh-mcp

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

OAuth Servers:
  • Atlassian (Jira/Confluence)
  • Webex APIs
  • Datadog US Region
  • Datadog EU Region
  • ArgoCD Sandbox

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Ready to try it? Run:

  claude-start --refresh-mcp

EOF
