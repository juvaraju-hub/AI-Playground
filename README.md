# AI-Playground

Shareable Claude Code skills and tools for development teams.

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
- ✅ MCP server configuration checks
- ✅ Optional OAuth MCP refresh before launching Codex

[Full Documentation →](tools/codex-start/README.md)

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

## 📖 Resources

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
