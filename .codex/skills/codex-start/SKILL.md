---
name: codex-start
description: Bootstrap and preflight checks for Codex development environments. Validates setup, verifies MCP registrations including Terraform, and checks core tooling before work begins.
---

# codex-start

Use this skill when starting work in Codex, onboarding a repo, or troubleshooting local environment issues.

## Usage

```bash
/codex-start
/codex-start --refresh-mcp
/codex-start --full
/codex-start --skip-aws
/codex-start --skip-k8s
```

## What It Checks

1. Repository status and local changes
2. Core development tools and language runtimes
3. Codex MCP setup, including Terraform MCP registration
4. Terraform guardrails in `~/.config/codex/mcp-terraform.env`
5. AWS and Kubernetes context, unless skipped
6. Project-local custom checks from `.codex-start.sh`

## Implementation

Run:

```bash
bash .codex/skills/codex-start/preflight.sh $ARGS
```

## Guardrails

- Terraform MCP checks are read-only validation only.
- Expect `READ_ONLY_TOOLS=true` and `ENABLE_DELETE_TOOLS=false` in the Terraform MCP env file.
- Do not print secret values from local env files.
