# codex-start

Reusable Codex preflight launcher for team use.

It checks the local dependencies and auth state that usually block a Codex session:

- GitHub CLI auth
- AWS CLI auth
- current or configured Kubernetes contexts
- passive MCP server configuration
- OAuth MCP login refresh for selected servers

Then it launches `codex`.

## Files

- `bin/codex-start`: main launcher
- `install.sh`: installs `codex-start` into `~/bin` by default

## Install

```bash
git clone <your-team-repo-url> codex-start
cd codex-start
./install.sh
```

If `~/bin` is not on `PATH`, add:

```bash
export PATH="$HOME/bin:$PATH"
```

Optional aliases:

```bash
alias cx=codex-start
alias cxc='codex-start --check-only'
```

## Usage

```bash
codex-start
codex-start --refresh-mcp
codex-start --check-only
codex-start -- --model gpt-5.4
```

## Supported flags

- `--check-only`: run checks without launching Codex
- `--no-launch`: run preflight only
- `--yes` or `--no-prompt`: auto-accept suggested login actions
- `--refresh-mcp`: prompt to refresh OAuth MCP servers this run
- `--open-aws-console`: open AWS Console after auth succeeds

## Environment variables

```bash
export CODEX_START_AWS_PROFILE=aidevops
export CODEX_START_KUBE_CONTEXTS="dev-sre-1-us-west-2 tools-sre-us-west-2"
export CODEX_START_MCP_OAUTH_SERVERS="atlassian webexapis"
export CODEX_START_MCP_PASSIVE_SERVERS="chrome-devtools kubernetes terraform-cloud terraform argocd-sbx github context7 datadog_us datadog_eu aws-knowledge-mcp-server openaiDeveloperDocs victorops"
export CODEX_START_REFRESH_MCP=1
```

Default passive MCP checks cover:

- `chrome-devtools`
- `kubernetes`
- `terraform-cloud`
- `terraform`
- `argocd-sbx`
- `github`
- `context7`
- `datadog_us`
- `datadog_eu`
- `aws-knowledge-mcp-server`
- `openaiDeveloperDocs`
- `victorops`

## Team rollout notes

Everyone on the team should already have these installed and configured locally:

- `codex`
- `gh`
- `aws`
- `kubectl`

`codex-start` only orchestrates the checks and login flow. It does not install those tools or create MCP server definitions for the user.
