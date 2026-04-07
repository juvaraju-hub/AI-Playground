#!/bin/bash
# Claude Code startup script - sets up environment for MCP servers
# Similar to Codex startup configuration

# Export environment variables needed by MCP servers
export GITHUB_PAT_TOKEN="${GITHUB_PAT_TOKEN:-$(security find-generic-password -s github_pat -w 2>/dev/null)}"
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

# Ensure required directories exist
mkdir -p ~/.claude/projects
mkdir -p ~/.config/claude-code

echo "Claude Code environment initialized"
echo "MCP servers available:"
echo "  - atlassian (remote)"
echo "  - chrome-devtools (npx)"
echo "  - kubernetes (npx)"
echo "  - terraform-cloud (uv)"
echo "  - webexapis (remote)"
echo "  - terraform (uv)"
echo "  - argocd-sbx (remote)"
echo "  - github (remote)"
echo "  - context7 (npx)"
echo "  - datadog_us (remote)"
echo "  - datadog_eu (remote)"
echo "  - aws-knowledge-mcp-server (remote)"
echo "  - openaiDeveloperDocs (remote)"
echo "  - victorops (uv)"
