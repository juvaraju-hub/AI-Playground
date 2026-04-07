#!/bin/bash
# Register all MCP servers from Codex config to Claude Code

set -e

log() {
  echo "[register-mcps] $*"
}

error() {
  echo "[register-mcps] ERROR: $*" >&2
  exit 1
}

if ! command -v claude &> /dev/null; then
  error "claude command not found in PATH"
fi

log "Starting MCP server registration..."
log "This will register all 14 MCP servers at user scope"
echo ""

# HTTP/Remote servers
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "Registering HTTP/Remote MCP servers..."
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

servers=(
  "atlassian|https://mcp.atlassian.com/v1/mcp"
  "webexapis|https://aicoding-mcp-webexapis.cisco.com/mcp/"
  "argocd-sbx|https://mcp-argocd-sbx.aiteam.cisco.com/mcp"
  "github|https://api.githubcopilot.com/mcp/"
  "datadog_us|https://mcp.datadoghq.com/api/unstable/mcp-server/mcp"
  "datadog_eu|https://mcp.datadoghq.eu/api/unstable/mcp-server/mcp"
  "aws-knowledge-mcp-server|https://knowledge-mcp.global.api.aws"
  "openaiDeveloperDocs|https://developers.openai.com/mcp"
)

for server_info in "${servers[@]}"; do
  IFS='|' read -r name url <<< "$server_info"

  # Check if already exists
  if claude mcp get "$name" &> /dev/null; then
    log "✓ $name already registered, skipping"
    continue
  fi

  log "Adding $name..."
  if claude mcp add --scope user --transport http "$name" "$url"; then
    log "  ✓ $name registered successfully"
  else
    log "  ✗ Failed to register $name"
  fi
done

echo ""
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "Registering STDIO MCP servers (npx)..."
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Chrome DevTools
name="chrome-devtools"
if claude mcp get "$name" &> /dev/null; then
  log "✓ $name already registered, skipping"
else
  log "Adding $name..."
  if claude mcp add --scope user "$name" -- npx chrome-devtools-mcp@latest; then
    log "  ✓ $name registered successfully"
  else
    log "  ✗ Failed to register $name"
  fi
fi

# Kubernetes
name="kubernetes"
if claude mcp get "$name" &> /dev/null; then
  log "✓ $name already registered, skipping"
else
  log "Adding $name..."
  if claude mcp add --scope user -e "KUBECONFIG=$HOME/.kube/config" "$name" -- npx -y kubernetes-mcp-server@latest; then
    log "  ✓ $name registered successfully"
  else
    log "  ✗ Failed to register $name"
  fi
fi

# Context7
name="context7"
if claude mcp get "$name" &> /dev/null; then
  log "✓ $name already registered, skipping"
else
  log "Adding $name..."
  if claude mcp add --scope user "$name" -- npx -y @upstash/context7-mcp; then
    log "  ✓ $name registered successfully"
  else
    log "  ✗ Failed to register $name"
  fi
fi

echo ""
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "Registering STDIO MCP servers (uv)..."
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Terraform Cloud
name="terraform-cloud"
if claude mcp get "$name" &> /dev/null; then
  log "✓ $name already registered, skipping"
else
  log "Adding $name..."
  # Get TFC_TOKEN from environment variable
  if [[ -z "${TFC_TOKEN:-}" ]]; then
    warn "  TFC_TOKEN environment variable not set"
    warn "  Set it with: export TFC_TOKEN='your-token-here'"
    log "  Skipping $name"
  elif claude mcp add --scope user -e "TFC_TOKEN=$TFC_TOKEN" "$name" -- uv run terraform-cloud-mcp; then
    log "  ✓ $name registered successfully"
  else
    log "  ✗ Failed to register $name"
  fi
fi

# Terraform (with env file)
name="terraform"
if claude mcp get "$name" &> /dev/null; then
  log "✓ $name already registered, skipping"
else
  log "Adding $name..."
  if [[ ! -f "$HOME/.config/codex/mcp-terraform.env" ]]; then
    log "  ⚠️  Warning: $HOME/.config/codex/mcp-terraform.env not found"
    log "  Skipping $name"
  else
    # Note: claude mcp add doesn't support --env-file, so we need to use a workaround
    # We'll add it but note that the env file won't be automatically loaded
    log "  ⚠️  Note: Environment file handling requires manual setup"
    if claude mcp add --scope user "$name" -- uv run --env-file "$HOME/.config/codex/mcp-terraform.env" --directory "$HOME/mcp/terraform-cloud-mcp" terraform-cloud-mcp; then
      log "  ✓ $name registered successfully (check env file is sourced)"
    else
      log "  ✗ Failed to register $name"
    fi
  fi
fi

# VictorOps
name="victorops"
if claude mcp get "$name" &> /dev/null; then
  log "✓ $name already registered, skipping"
else
  log "Adding $name..."
  if [[ ! -f "$HOME/.config/codex/mcp-victorops.env" ]]; then
    log "  ⚠️  Warning: $HOME/.config/codex/mcp-victorops.env not found"
    log "  Skipping $name"
  else
    log "  ⚠️  Note: Environment file handling requires manual setup"
    if claude mcp add --scope user "$name" -- uv run --env-file "$HOME/.config/codex/mcp-victorops.env" --directory "$HOME/aispg/victorops-mcp" victorops-mcp --transport stdio; then
      log "  ✓ $name registered successfully (check env file is sourced)"
    else
      log "  ✗ Failed to register $name"
    fi
  fi
fi

echo ""
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "Registration complete!"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log "Checking registered servers..."
claude mcp list
echo ""
log "All done! Run 'claude' to start using your MCP servers."
