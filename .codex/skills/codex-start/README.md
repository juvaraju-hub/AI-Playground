# Codex Start Skill

Bootstrap and preflight validation for development teams using Codex.

## Quick Start

```bash
/codex-start
/codex-start --refresh-mcp
/codex-start --full
/codex-start --skip-aws
/codex-start --skip-k8s
```

## What It Checks

✅ Git repository status and branch
✅ Development tools and language runtimes
✅ Codex MCP connectivity
✅ Terraform MCP registration and guardrail validation
✅ Cloud credentials (AWS)
✅ Kubernetes context and namespace
✅ Project-specific custom checks

## Terraform MCP

`codex-start` verifies that the `terraform` MCP is registered and that the local env file uses safe defaults.

Expected env file:

```bash
~/.config/codex/mcp-terraform.env
```

Recommended contents:

```bash
TFC_TOKEN=...
TFC_ADDRESS=https://app.terraform.io
ENABLE_DELETE_TOOLS=false
READ_ONLY_TOOLS=true
```

Registration command:

```bash
codex mcp add terraform -- uv run --env-file ~/.config/codex/mcp-terraform.env --directory /path/to/terraform-cloud-mcp terraform-cloud-mcp
codex mcp get terraform
```

## Custom Project Checks

Create `.codex-start.sh` in your repo root to add project-specific validation.
