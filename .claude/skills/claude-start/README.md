# Claude Start Skill

Universal bootstrap and preflight validation skill for development teams using Claude Code.

## 🚀 Quick Start

In any Claude Code session:

```bash
/claude-start                    # Run quick environment checks
/claude-start --refresh-mcp      # Reconnect to MCP servers
/claude-start --full             # Run comprehensive checks
/claude-start --skip-aws         # Skip AWS checks
/claude-start --skip-k8s         # Skip Kubernetes checks
```

## 📋 What It Checks

✅ Git repository status and branch
✅ Development tools (git, node, python, docker, etc.)
✅ MCP server connectivity
✅ Cloud credentials (AWS, GCP, Azure)
✅ Kubernetes context and namespace
✅ Language-specific dependencies
✅ Custom project requirements

## 📦 Installation

### Option 1: Add to Your Repository

```bash
# Copy the skill to your repo
mkdir -p .claude/skills
cp -r claude-start .claude/skills/

# Commit and push
git add .claude/skills/claude-start
git commit -m "Add claude-start skill"
git push
```

Team members automatically get the skill when they pull your repo!

### Option 2: Standalone Script

You can also run the preflight script directly without Claude Code:

```bash
# Make it executable
chmod +x .claude/skills/claude-start/preflight.sh

# Run it
./claude/skills/claude-start/preflight.sh --full
```

### Option 3: Global Installation

Install in your home directory for use across all projects:

```bash
mkdir -p ~/.claude/skills
cp -r claude-start ~/.claude/skills/
```

## 🎯 Common Use Cases

### Starting Your Day
```bash
/claude-start --refresh-mcp
```
Validates your environment and refreshes all MCP connections.

### Onboarding New Team Members
```bash
/claude-start --full
```
Identifies missing tools and configuration issues.

### Before Deployment
```bash
/claude-start --full
```
Comprehensive checks including production warnings.

### Troubleshooting Environment Issues
```bash
/claude-start
```
Quick diagnostic of common setup problems.

### CI/CD Pre-flight
```bash
bash .claude/skills/claude-start/preflight.sh --skip-aws --skip-k8s
```
Validate environment in automated pipelines.

## 🔧 Customization

### Add Project-Specific Checks

Create `.claude-start.sh` in your repo root:

```bash
#!/bin/bash
# Custom checks for this project

echo "🔍 Project-Specific Checks"

# Check if database is running
if ! pg_isready -h localhost -p 5432 &> /dev/null; then
  echo "⚠️  PostgreSQL not running"
  echo "💡 Run: docker-compose up -d postgres"
fi

# Check if .env file exists
if [[ ! -f ".env" ]]; then
  echo "⚠️  .env file missing"
  echo "💡 Run: cp .env.example .env"
fi

# Verify API is reachable
if ! curl -sf http://localhost:8080/health &> /dev/null; then
  echo "⚠️  API not responding"
  echo "💡 Run: npm run dev"
fi

# Check Node version matches .nvmrc
if [[ -f ".nvmrc" ]]; then
  required=$(cat .nvmrc)
  current=$(node --version)
  if [[ "$current" != "$required" ]]; then
    echo "⚠️  Node version mismatch"
    echo "   Required: $required"
    echo "   Current: $current"
    echo "💡 Run: nvm use"
  fi
fi
```

### Environment-Specific Configuration

Add checks for different environments:

```bash
# .claude-start.sh

ENVIRONMENT=${ENVIRONMENT:-development}

case $ENVIRONMENT in
  production)
    echo "🔴 PRODUCTION ENVIRONMENT"
    # Extra validation for prod
    ;;
  staging)
    echo "🟡 STAGING ENVIRONMENT"
    ;;
  development)
    echo "🟢 DEVELOPMENT ENVIRONMENT"
    ;;
esac
```

## 🔌 MCP Server Integration

The `--refresh-mcp` flag helps reconnect to MCP servers. Common servers include:

| Server | Purpose | How to Connect |
|--------|---------|----------------|
| **atlassian** | Jira/Confluence | `/mcp` → Atlassian |
| **github** | GitHub API | `/mcp` → GitHub |
| **slack** | Team messaging | `/mcp` → Slack |
| **webexapis** | Webex collaboration | `/mcp` → Webex |
| **postgres** | Database access | Configure in settings |
| **playwright** | Browser automation | Install via MCP |

### First-Time MCP Setup

1. In Claude Code, run: `/mcp`
2. Select "Add server" or "Connect"
3. Authenticate via OAuth
4. Run `/claude-start --refresh-mcp` to verify

## 📖 Team Adoption Guide

### For Team Leads

1. **Add to your main repository:**
   ```bash
   cp -r claude-start path/to/your/repo/.claude/skills/
   cd path/to/your/repo
   git add .claude/skills/claude-start
   git commit -m "Add claude-start skill for team"
   git push
   ```

2. **Document in your README:**
   ```markdown
   ## Getting Started with Claude Code

   Run preflight checks:
   ```bash
   /claude-start --full
   ```

   This will validate your environment and guide you through setup.
   ```

3. **Add to onboarding docs:**
   - Mention the skill in onboarding documentation
   - Include `/claude-start` as first step
   - Document any custom `.claude-start.sh` checks

### For Team Members

1. **Pull latest code:**
   ```bash
   git pull origin main
   ```

2. **Run the skill:**
   ```bash
   /claude-start --full
   ```

3. **Fix any issues reported:**
   - Install missing tools
   - Configure credentials
   - Set up MCP servers

## 🛠️ Extending the Skill

### Add Language-Specific Checks

Edit `SKILL.md` to add checks for your stack:

```bash
# Ruby
if [[ -f "Gemfile" ]]; then
  echo "Ruby project detected"
  check_tool "ruby" "Ruby"
  check_tool "bundle" "Bundler"
  [[ -d "vendor/bundle" ]] && echo "✅ Gems installed" || echo "⚠️  Run: bundle install"
fi

# PHP
if [[ -f "composer.json" ]]; then
  echo "PHP project detected"
  check_tool "php" "PHP"
  check_tool "composer" "Composer"
  [[ -d "vendor" ]] && echo "✅ Dependencies installed" || echo "⚠️  Run: composer install"
fi
```

### Add Cloud Provider Checks

```bash
# GCP
if [[ "$CHECK_GCP" == true ]]; then
  check_tool "gcloud" "Google Cloud CLI"
  gcloud config get-value project
fi

# Azure
if [[ "$CHECK_AZURE" == true ]]; then
  check_tool "az" "Azure CLI"
  az account show
fi
```

### Add Security Checks

```bash
# Check for secrets in code
if command -v trufflehog &> /dev/null; then
  echo "🔒 Scanning for secrets..."
  trufflehog filesystem . --only-verified
fi

# Check dependencies for vulnerabilities
if [[ -f "package.json" ]]; then
  npm audit --audit-level=high
fi
```

## 🔍 Troubleshooting

### "Skill not found"
- Ensure `.claude/skills/claude-start/SKILL.md` exists
- Check you're in the correct directory
- Try restarting Claude Code

### "MCP authentication failed"
- Run `/mcp` directly
- Select the server to reconnect
- Complete OAuth flow
- Run `/claude-start --refresh-mcp` again

### "Tool not found"
Install missing tools:

```bash
# macOS
brew install aws-cli kubectl terraform gh jq

# Ubuntu/Debian
apt-get install awscli kubectl terraform gh jq

# Windows (Chocolatey)
choco install awscli kubernetes-cli terraform gh jq
```

### "AWS credentials expired"
```bash
# For SSO
aws sso login

# For profiles
aws sso login --profile my-profile

# Configure new credentials
aws configure
```

## 📊 Examples

### Successful Run
```
📁 Repository Check
✅ Branch: feature/new-api
✅ Clean working tree

🔧 Development Tools
✅ Git: 2.40.0
✅ Node.js: v20.11.0
✅ Docker: 24.0.7
✅ Terraform: 1.7.0

☁️  AWS Environment
Region: us-west-2
Account: 123456789012
Identity: arn:aws:iam::123456789012:user/developer

✅ Preflight checks complete!
```

### With Issues Detected
```
📁 Repository Check
✅ Branch: main
⚠️  Uncommitted changes present
   M src/api/handler.js
   ?? .env

🔧 Development Tools
✅ Git: 2.40.0
❌ Docker: Not installed
⚠️  Run: brew install docker

☁️  AWS Environment
⚠️  AWS credentials not configured or expired
💡 Run: aws sso login
```

## 🤝 Contributing

Improvements welcome! Common additions:
- New language runtime checks
- Additional cloud provider support
- Security scanning integrations
- Performance benchmarking
- Dependency update notifications

## 📝 License

Free to use and modify for your team's needs.

## 🆘 Support

- Check the [SKILL.md](SKILL.md) for implementation details
- Review [preflight.sh](preflight.sh) for script logic
- Create custom `.claude-start.sh` for your project
- Share improvements with your team!

---

**Made for teams using Claude Code** 🤖
