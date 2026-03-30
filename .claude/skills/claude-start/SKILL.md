---
name: claude-start
description: Bootstrap and preflight checks for development environment. Validates setup, refreshes MCP servers, and ensures all tools are ready. Use when starting work, troubleshooting environment issues, or onboarding new team members.
tools: Bash, Read, Grep, Glob
args: --refresh-mcp (refresh MCP server connections), --full (run all checks), --skip-aws (skip AWS checks), --skip-k8s (skip Kubernetes checks)
---

# Claude Start - Development Environment Bootstrap

Automated preflight checks and environment setup for development teams.

## Usage

```bash
/claude-start                    # Quick environment checks
/claude-start --refresh-mcp      # Reconnect to MCP servers
/claude-start --full             # Comprehensive checks
/claude-start --skip-aws         # Skip AWS credential checks
/claude-start --skip-k8s         # Skip Kubernetes checks
```

## What This Skill Does

1. **Environment Validation**
   - Verify git repository status
   - Check current branch and uncommitted changes
   - Verify required tools are installed

2. **MCP Server Management**
   - Refresh connections to configured MCP servers (Atlassian, Webex, GitHub, etc.)
   - Verify MCP server connectivity
   - Guide through authentication if needed

3. **Cloud Environment** (optional)
   - Check AWS CLI configuration
   - Verify current AWS account/region
   - Validate credentials are active
   - Support for other cloud providers (GCP, Azure)

4. **Kubernetes Context** (optional)
   - Display current kubectl context
   - Show available clusters
   - Warn if in production context

5. **Development Tools**
   - Check language runtimes (Node, Python, Go, etc.)
   - Verify build tools (npm, pip, cargo, etc.)
   - Show tool versions

## Implementation

### Step 1: Parse Arguments

```bash
# Parse flags from ARGS variable
REFRESH_MCP=false
FULL_CHECK=false
SKIP_AWS=false
SKIP_K8S=false

for arg in $ARGS; do
  case $arg in
    --refresh-mcp) REFRESH_MCP=true ;;
    --full) FULL_CHECK=true ;;
    --skip-aws) SKIP_AWS=true ;;
    --skip-k8s) SKIP_K8S=true ;;
  esac
done
```

### Step 2: Repository Validation

```bash
echo "📁 Repository Check"

# Show git status
if git rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git branch --show-current)
  echo "✅ Branch: $branch"

  # Check for uncommitted changes
  if [[ -n $(git status --short) ]]; then
    echo "⚠️  Uncommitted changes present"
    git status --short
  fi

  # Show recent commits
  echo "Recent commits:"
  git log --oneline -5
else
  echo "⚠️  Not a git repository"
fi
```

### Step 3: MCP Server Refresh

When `--refresh-mcp` is present, inform the user that MCP refresh is requested and guide them:

```bash
if [[ "$REFRESH_MCP" == true ]]; then
  echo "🔄 MCP Server Refresh Requested"
  echo ""
  echo "To refresh MCP servers, run the /mcp command in Claude Code:"
  echo "  1. Type: /mcp"
  echo "  2. Select 'Reconnect' for each server"
  echo "  3. Complete any OAuth flows if prompted"
  echo ""
  echo "Common MCP servers to refresh:"
  echo "  • atlassian (Jira/Confluence)"
  echo "  • webexapis (Webex)"
  echo "  • github (GitHub)"
  echo "  • slack (Slack)"
fi
```

### Step 4: Tool Checks

```bash
echo "🔧 Development Tools"

# Core tools
check_tool() {
  local cmd=$1
  local name=$2

  if command -v "$cmd" &> /dev/null; then
    version=$($cmd --version 2>&1 | head -1)
    echo "✅ $name: $version"
  else
    echo "❌ $name: Not installed"
  fi
}

# Essential tools
check_tool "git" "Git"
check_tool "curl" "cURL"
check_tool "jq" "JSON Processor"

# Language runtimes (if present)
check_tool "node" "Node.js"
check_tool "python3" "Python"
check_tool "go" "Go"
check_tool "cargo" "Rust"
check_tool "java" "Java"

# Cloud tools (if needed)
if [[ "$SKIP_AWS" != true ]]; then
  check_tool "aws" "AWS CLI"
fi

if [[ "$SKIP_K8S" != true ]]; then
  check_tool "kubectl" "Kubernetes CLI"
fi

# Container tools
check_tool "docker" "Docker"
check_tool "terraform" "Terraform"

# Version control
check_tool "gh" "GitHub CLI"
```

### Step 5: Cloud Environment Check (AWS Example)

```bash
if [[ "$SKIP_AWS" != true ]] && command -v aws &> /dev/null; then
  echo "☁️  AWS Environment"

  aws_region=$(aws configure get region 2>&1 || echo "not-set")
  echo "Region: $aws_region"

  # Try to get current account
  if account_id=$(aws sts get-caller-identity --query Account --output text 2>&1); then
    echo "Account: $account_id"

    # Get current identity
    identity=$(aws sts get-caller-identity --query Arn --output text 2>&1)
    echo "Identity: $identity"
  else
    echo "⚠️  AWS credentials not configured or expired"
    echo "💡 Run: aws configure"
    echo "💡 Or: aws sso login"
  fi
fi
```

### Step 6: Kubernetes Context Check

```bash
if [[ "$SKIP_K8S" != true ]] && command -v kubectl &> /dev/null; then
  echo "⎈  Kubernetes"

  if current_context=$(kubectl config current-context 2>&1); then
    echo "Context: $current_context"

    # Warn if in production
    if [[ $current_context =~ prod|production ]]; then
      echo "🔴 WARNING: Production context detected!"
    fi

    # Show namespace
    namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>&1)
    echo "Namespace: ${namespace:-default}"

    # List available contexts
    echo "Available contexts:"
    kubectl config get-contexts -o name | head -5
  else
    echo "⚠️  No kubernetes context configured"
  fi
fi
```

### Step 7: Language-Specific Checks

```bash
if [[ "$FULL_CHECK" == true ]]; then
  echo "📦 Language Environments"

  # Node.js
  if [[ -f "package.json" ]]; then
    echo "Node.js project detected"
    [[ -d "node_modules" ]] && echo "✅ Dependencies installed" || echo "⚠️  Run: npm install"
  fi

  # Python
  if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
    echo "Python project detected"
    if [[ -d "venv" ]] || [[ -d ".venv" ]]; then
      echo "✅ Virtual environment found"
    else
      echo "⚠️  Run: python -m venv venv"
    fi
  fi

  # Go
  if [[ -f "go.mod" ]]; then
    echo "Go project detected"
    go version
  fi

  # Rust
  if [[ -f "Cargo.toml" ]]; then
    echo "Rust project detected"
    cargo --version
  fi
fi
```

### Step 8: Custom Project Checks

```bash
# Source custom checks if present
if [[ -f ".claude-start.sh" ]]; then
  echo "🔍 Custom Project Checks"
  source .claude-start.sh
fi
```

### Step 9: Summary and Tips

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Preflight checks complete!"
echo ""
echo "💡 Quick Tips:"
echo "   • /claude-start --refresh-mcp    Refresh MCP connections"
echo "   • /claude-start --full           Run comprehensive checks"
echo "   • Create .claude-start.sh        Add custom project checks"
echo ""
echo "📚 Useful Commands:"
echo "   • git status                     Check repository status"
echo "   • gh pr list                     List your pull requests"
echo "   • docker ps                      List running containers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

## Customization

### Project-Specific Checks

Create `.claude-start.sh` in your repo root:

```bash
#!/bin/bash
# .claude-start.sh - Custom project checks

echo "Running custom checks..."

# Example: Check if services are running
if ! curl -s http://localhost:3000 > /dev/null; then
  echo "⚠️  Development server not running"
  echo "💡 Run: npm run dev"
fi

# Example: Check environment variables
if [[ -z "$API_KEY" ]]; then
  echo "⚠️  API_KEY not set"
  echo "💡 Run: source .env"
fi

# Example: Validate configuration
if [[ ! -f ".env" ]]; then
  echo "⚠️  .env file missing"
  echo "💡 Run: cp .env.example .env"
fi
```

### Team Standards

Add project conventions to check:
- Branch naming (e.g., `feature/`, `bugfix/`)
- Commit message format
- Required environment variables
- Service dependencies
- Database migrations status

## MCP Server Guide

Common MCP servers your team might use:

| Server | What It Provides | Setup Command |
|--------|------------------|---------------|
| atlassian | Jira, Confluence access | `/mcp` → Connect Atlassian |
| github | Issues, PRs, Actions | `/mcp` → Connect GitHub |
| slack | Team messaging | `/mcp` → Connect Slack |
| postgres | Database queries | Configure in settings |
| filesystem | File operations | Built-in |

## Troubleshooting

### MCP Authentication Issues
1. Run `/mcp` in Claude Code
2. Select the server to reconnect
3. Complete OAuth flow in browser
4. Return to Claude and retry

### AWS Credentials Expired
```bash
# For SSO
aws sso login --profile <profile>

# For access keys
aws configure
```

### Kubernetes Access
```bash
# Update kubeconfig
aws eks update-kubeconfig --name <cluster> --region <region>

# Or for other providers
gcloud container clusters get-credentials <cluster>
az aks get-credentials --name <cluster> --resource-group <group>
```

## Integration with CI/CD

Run as a pre-commit hook:

```bash
# .git/hooks/pre-commit
#!/bin/bash
bash .claude/skills/claude-start/preflight.sh --skip-aws --skip-k8s
```

## Team Sharing

To share this skill with your team:

1. **Commit to your repo:**
   ```bash
   git add .claude/skills/claude-start/
   git commit -m "Add claude-start skill"
   git push
   ```

2. **Team members pull and use:**
   ```bash
   git pull
   /claude-start
   ```

3. **Or create as a plugin** for installation across multiple repos
