# AI-Playground

Shareable Claude Code skills and tools for development teams.

## 🚀 Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/juvaraju-hub/AI-Playground/main/scripts/install.sh | bash
```

That's it! For detailed setup, see:
- **[QUICKSTART.md](QUICKSTART.md)** - 5-minute quick start guide
- **[INSTALL.md](INSTALL.md)** - Complete installation guide with prerequisites

---

## 📦 What's Inside

### Claude Start Skill

Universal bootstrap and preflight validation skill for development environments.

**Location:** `.claude/skills/claude-start/`

**Quick start:**
```bash
/claude-start                    # Quick checks
/claude-start --refresh-mcp      # Refresh MCP connections
/claude-start --full             # Comprehensive validation
```

**Features:**
- ✅ Environment validation
- ✅ MCP server management
- ✅ Terraform MCP verification with read-only guardrails
- ✅ Cloud credentials check (AWS, GCP, Azure)
- ✅ Kubernetes context validation
- ✅ Language runtime checks
- ✅ Custom project checks

[Full Documentation →](.claude/skills/claude-start/README.md)

### Codex Start

Reusable Codex preflight launcher for development teams.

**Location:** `tools/codex-start/`

**Quick start:**
```bash
cd tools/codex-start
./install.sh

codex-start
codex-start --refresh-mcp
codex-start --check-only
```

**Features:**
- ✅ GitHub CLI auth check
- ✅ AWS CLI auth check
- ✅ Kubernetes context validation
- ✅ MCP server configuration checks for the full local stack
- ✅ Optional OAuth MCP refresh before launching Codex

By default, `codex-start` verifies these passive MCP registrations:
`chrome-devtools`, `kubernetes`, `terraform-cloud`, `terraform`, `argocd-sbx`, `github`, `context7`, `datadog_us`, `datadog_eu`, `aws-knowledge-mcp-server`, `openaiDeveloperDocs`, and `victorops`.

OAuth refresh remains focused on `atlassian` and `webexapis`.

[Full Documentation →](tools/codex-start/README.md)

### Claude Start (Launcher)

Reusable Claude Code preflight launcher with enhanced MCP management and individual OAuth control.

**Location:** `tools/claude-start/`

**Quick start:**
```bash
cd tools/claude-start
./install.sh

claude-start
claude-start --refresh-mcp      # Individual OAuth control
claude-start --check-only
```

**Features:**
- ✅ GitHub CLI auth check
- ✅ AWS CLI auth check
- ✅ Kubernetes context validation
- ✅ 14 MCP servers configured (migrated from Codex)
- ✅ **Individual OAuth control** - Choose which servers to authenticate
- ✅ Automatic browser-based OAuth flows
- ✅ Datadog US and EU handled separately

**MCP Servers (14 total):**
- **OAuth (5):** atlassian, webexapis, datadog_us, datadog_eu, argocd-sbx
- **Passive (9):** github, context7, terraform, terraform-cloud, victorops, aws-knowledge-mcp-server, openaiDeveloperDocs, kubernetes, chrome-devtools

[Full MCP Documentation →](docs/mcp-setup/INDEX.md)

### Codex Start Skill

Parallel bootstrap and preflight validation skill for Codex environments.

**Location:** `.codex/skills/codex-start/`

**Quick start:**
```bash
/codex-start                     # Quick checks
/codex-start --refresh-mcp       # Refresh MCP connections
/codex-start --full              # Comprehensive validation
```

**Features:**
- ✅ Environment validation
- ✅ MCP server management
- ✅ Terraform MCP verification with read-only guardrails
- ✅ Cloud credentials check (AWS, GCP, Azure)
- ✅ Kubernetes context validation
- ✅ Language runtime checks
- ✅ Custom project checks

[Full Documentation →](.codex/skills/codex-start/README.md)

## 📖 Documentation

| Guide | Description |
|-------|-------------|
| [QUICKSTART.md](QUICKSTART.md) | 5-minute quick start |
| [INSTALL.md](INSTALL.md) | Complete installation guide |
| [docs/mcp-setup/INDEX.md](docs/mcp-setup/INDEX.md) | MCP setup documentation |
| [docs/mcp-setup/OAUTH_GUIDE.md](docs/mcp-setup/OAUTH_GUIDE.md) | OAuth authentication |
| [docs/mcp-setup/QUICKSTART.txt](docs/mcp-setup/QUICKSTART.txt) | Quick reference card |

## 🚀 Using These Skills in Your Project

### Option 1: Copy to Your Repo

```bash
# Clone this repo
git clone <your-repo-url> AI-Playground
cd AI-Playground

# Copy skills to your project
cp -r .claude/skills/claude-start /path/to/your/project/.claude/skills/

# In your project, commit the skill
cd /path/to/your/project
git add .claude/skills/claude-start
git commit -m "Add claude-start skill"
git push
```

### Option 2: Use as Submodule

```bash
cd /path/to/your/project

# Add as submodule
git submodule add <your-repo-url> .claude/skills-library
git submodule update --init --recursive

# Symlink the skill
ln -s .claude/skills-library/.claude/skills/claude-start .claude/skills/claude-start
```

### Option 3: Global Installation

```bash
# Install globally in your Claude config
mkdir -p ~/.claude/skills
cp -r .claude/skills/claude-start ~/.claude/skills/
```

## 📚 Available Skills

| Skill | Description | Usage |
|-------|-------------|-------|
| **claude-start** | Environment bootstrap & preflight | `/claude-start [--refresh-mcp] [--full]` |
| **codex-start** | Codex environment bootstrap & preflight | `/codex-start [--refresh-mcp] [--full]` |

More skills coming soon!

## 🧰 Available Tools

| Tool | Description | Usage |
|------|-------------|-------|
| **codex-start** | Codex bootstrap & preflight launcher | `codex-start [--refresh-mcp] [--check-only]` |
| **claude-start** | Claude Code launcher with OAuth control | `claude-start [--refresh-mcp] [--check-only]` |

### Claude Start Features

The **claude-start** launcher includes advanced MCP OAuth management:

- **Individual Control:** Each OAuth server asks separately - YOU choose which to authenticate now vs later
- **Datadog Separation:** US and EU regions handled independently
- **Friendly Names:** "Atlassian (Jira/Confluence)" not "atlassian"
- **Usage Examples:** Shows how to use each server
- **Detailed Summary:** Connected/Authenticated/Skipped counts

```bash
# Interactive - choose which servers to authenticate
claude-start --refresh-mcp

# Example flow:
# → Authenticate Atlassian (Jira/Confluence) now? (y/N) y
# → Authenticate Datadog US Region now? (y/N) y
# → Authenticate Datadog EU Region now? (y/N) n  ← Skip for later
#
# Summary:
#   ✓ Already connected:     2 server(s)
#   ✓ Authenticated now:     2 server(s)
#   ⊘ Skipped (for later):   1 server(s)
```

[Complete MCP Setup Guide →](docs/mcp-setup/INDEX.md)

## 🤝 Contributing

Want to add more skills? Great!

1. Create a new skill directory: `.claude/skills/your-skill-name/`
2. Add `SKILL.md` with the skill definition
3. Add `README.md` with documentation
4. Add any helper scripts
5. Update this main README
6. Submit a pull request

### Skill Structure

```
.claude/skills/your-skill-name/
├── SKILL.md          # Skill definition (required)
├── README.md         # User documentation
└── helpers/          # Optional helper scripts
```

## 🎯 Team Sharing Best Practices

1. **Commit skills to your main repo** - Team members get them automatically
2. **Document in onboarding** - Add `/claude-start` to new dev setup
3. **Customize with `.claude-start.sh`** - Add project-specific checks
4. **Keep skills updated** - Pull improvements from this repo periodically

## 🏃 Quick Start for New Team Members

### 1. Install Everything
```bash
curl -fsSL https://raw.githubusercontent.com/juvaraju-hub/AI-Playground/main/scripts/install.sh | bash
```

### 2. Reload Shell
```bash
source ~/.zshrc  # or ~/.bashrc
```

### 3. Run Preflight
```bash
claude-start --check-only  # or codex-start
```

### 4. Set Up OAuth (Claude Code)
```bash
claude-start --refresh-mcp
```

**Done!** See [QUICKSTART.md](QUICKSTART.md) for more details.

## 📖 Resources

- **Installation**
  - [Quick Start Guide](QUICKSTART.md)
  - [Full Installation Guide](INSTALL.md)
  - [MCP Setup](docs/mcp-setup/INDEX.md)
- **External**
  - [Claude Code Documentation](https://docs.anthropic.com/claude/docs/claude-code)
  - [Creating Custom Skills](https://docs.anthropic.com/claude/docs/skills)
  - [MCP Servers](https://modelcontextprotocol.io/docs)

## 💡 Examples

### Team Onboarding
```bash
# New team member clones repo
git clone your-repo
cd your-repo

# Runs preflight checks
claude
/claude-start --full

# Or in Codex
/codex-start --full

# Or via the reusable launcher
codex-start --check-only

# Claude guides through any missing setup
```

### Daily Workflow
```bash
# Start of day
/claude-start --refresh-mcp
/codex-start --refresh-mcp
codex-start --refresh-mcp

# Before deployment
/claude-start --full
/codex-start --full
codex-start

# Quick status check
/claude-start
/codex-start
codex-start --check-only
```

### CI/CD Integration
```yaml
# .github/workflows/preflight.yml
name: Preflight Checks

on: [push, pull_request]

jobs:
  preflight:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run preflight checks
        run: bash .claude/skills/claude-start/preflight.sh --skip-aws --skip-k8s
```

### Terraform MCP Setup
If your team uses Terraform Cloud through Codex MCP, both `claude-start` and `codex-start` now check whether the `terraform` MCP is registered and whether its local guardrails are safe.

Expected local env file:

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

Register the MCP:

```bash
codex mcp add terraform -- uv run --env-file ~/.config/codex/mcp-terraform.env --directory /path/to/terraform-cloud-mcp terraform-cloud-mcp
codex mcp get terraform
```

## 🛠️ Customization Examples

### Project-Specific Checks

```bash
# .claude-start.sh in your project root

echo "🔍 Custom Checks for MyApp"

# Check if services are running
if ! curl -sf http://localhost:3000/health &> /dev/null; then
  echo "⚠️  API server not running"
  echo "💡 Run: npm run dev"
fi

# Check database connection
if ! pg_isready -h localhost &> /dev/null; then
  echo "⚠️  PostgreSQL not running"
  echo "💡 Run: docker-compose up -d postgres"
fi

# Validate required env vars
required_vars=("API_KEY" "DATABASE_URL" "REDIS_URL")
for var in "${required_vars[@]}"; do
  if [[ -z "${!var}" ]]; then
    echo "⚠️  $var not set"
    echo "💡 Check your .env file"
  fi
done
```

## 📝 License

MIT License - Feel free to use and modify for your team's needs.

## 🆘 Support

- Check individual skill READMEs for detailed documentation
- Open an issue for bugs or feature requests
- Share your custom skills with the community!

---

**Built for teams using Claude Code** 🤖
