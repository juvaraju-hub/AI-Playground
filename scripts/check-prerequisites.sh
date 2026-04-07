#!/usr/bin/env bash
# Prerequisites checker for AI-Playground
# Run this before installation to see what's missing

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
REQUIRED_MISSING=0
OPTIONAL_MISSING=0

# Helper functions
check_ok() {
  echo -e "${GREEN}✓${NC} $1"
}

check_warn() {
  echo -e "${YELLOW}⚠${NC} $1"
  OPTIONAL_MISSING=$((OPTIONAL_MISSING + 1))
}

check_fail() {
  echo -e "${RED}✗${NC} $1"
  REQUIRED_MISSING=$((REQUIRED_MISSING + 1))
}

check_command() {
  local cmd="$1"
  local name="$2"
  local install_hint="$3"
  local version_flag="${4:---version}"

  if command -v "$cmd" &> /dev/null; then
    local version=$($cmd $version_flag 2>&1 | head -1)
    check_ok "$name - $version"
    return 0
  else
    if [[ -n "$install_hint" ]]; then
      check_warn "$name not found"
      echo "   Install: $install_hint"
    else
      check_fail "$name not found"
    fi
    return 1
  fi
}

# Banner
cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║           AI-Playground Prerequisites Checker                 ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

EOF

echo -e "${BLUE}Checking system requirements...${NC}"
echo ""

# Required tools
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Required Tools${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Git
check_command git "Git" ""

# Shell
if [[ -n "$SHELL" ]]; then
  check_ok "Shell - $SHELL"
else
  check_fail "Shell not detected"
fi

# Claude or Codex
CLAUDE_FOUND=0
CODEX_FOUND=0

if command -v claude &> /dev/null; then
  CLAUDE_FOUND=1
  check_ok "Claude Code"
else
  check_warn "Claude Code not found"
  echo "   Install: https://claude.ai/download"
fi

if command -v codex &> /dev/null; then
  CODEX_FOUND=1
  check_ok "Codex"
else
  check_warn "Codex not found"
  echo "   Install: Contact your team admin"
fi

if [[ $CLAUDE_FOUND -eq 0 && $CODEX_FOUND -eq 0 ]]; then
  check_fail "Neither Claude Code nor Codex found - at least one is required"
  REQUIRED_MISSING=$((REQUIRED_MISSING + 1))
fi

echo ""

# Optional tools
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Optional Tools (for MCP and cloud checks)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# GitHub CLI
check_command gh "GitHub CLI" "brew install gh (macOS) or see https://cli.github.com" "--version"

# AWS CLI
check_command aws "AWS CLI" "brew install awscli (macOS) or see https://aws.amazon.com/cli" "--version"

# kubectl
check_command kubectl "kubectl" "brew install kubectl (macOS) or see https://kubernetes.io/docs/tasks/tools" "version --client"

# uv (Python)
check_command uv "uv (Python)" "curl -LsSf https://astral.sh/uv/install.sh | sh" "--version"

# npx (Node.js)
check_command npx "npx (Node.js)" "brew install node (macOS) or see https://nodejs.org" "--version"

# jq (for JSON parsing)
check_command jq "jq (JSON processor)" "brew install jq (macOS) or apt install jq (Linux)" "--version"

echo ""

# System info
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}System Information${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# OS
if [[ -f /etc/os-release ]]; then
  OS=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
  check_ok "OS - $OS"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macOS $(sw_vers -productVersion)"
  check_ok "OS - $OS"
else
  check_ok "OS - $OSTYPE"
fi

# Shell
SHELL_NAME=$(basename "$SHELL")
SHELL_VERSION=$($SHELL --version 2>&1 | head -1)
check_ok "Shell - $SHELL_NAME ($SHELL_VERSION)"

# Home directory
check_ok "Home - $HOME"

# ~/bin check
if [[ -d "$HOME/bin" ]]; then
  check_ok "~/bin directory exists"
else
  check_warn "~/bin directory doesn't exist (will be created)"
fi

# PATH check
if [[ ":$PATH:" == *":$HOME/bin:"* ]]; then
  check_ok "~/bin is in PATH"
else
  check_warn "~/bin is not in PATH (will be added)"
fi

echo ""

# Environment checks
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Environment Checks${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# GitHub auth
if command -v gh &> /dev/null; then
  if gh auth status &> /dev/null; then
    check_ok "GitHub authenticated"
  else
    check_warn "GitHub not authenticated (run: gh auth login)"
  fi
fi

# AWS auth
if command -v aws &> /dev/null; then
  if aws sts get-caller-identity &> /dev/null 2>&1; then
    check_ok "AWS authenticated"
  else
    check_warn "AWS not authenticated (run: aws sso login)"
  fi
fi

# Kubernetes context
if command -v kubectl &> /dev/null; then
  if kubectl config current-context &> /dev/null 2>&1; then
    KUBE_CTX=$(kubectl config current-context)
    check_ok "Kubernetes context - $KUBE_CTX"
  else
    check_warn "No Kubernetes context configured"
  fi
fi

# Check for existing MCPs (Claude Code)
if command -v claude &> /dev/null; then
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}Existing MCP Servers (Claude Code)${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""

  MCP_COUNT=$(claude mcp list 2>&1 | grep -E "^[a-z-]+:" | wc -l | tr -d ' ')
  if [[ $MCP_COUNT -gt 0 ]]; then
    check_ok "$MCP_COUNT MCP servers already configured"
    echo ""
    echo "Run 'claude mcp list' to see them"
  else
    check_warn "No MCP servers configured yet"
  fi
fi

echo ""

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [[ $REQUIRED_MISSING -eq 0 ]]; then
  echo -e "${GREEN}✓ All required tools are installed!${NC}"
else
  echo -e "${RED}✗ $REQUIRED_MISSING required tool(s) missing${NC}"
fi

if [[ $OPTIONAL_MISSING -gt 0 ]]; then
  echo -e "${YELLOW}⚠ $OPTIONAL_MISSING optional tool(s) missing${NC}"
  echo "   (These are recommended but not required)"
fi

echo ""

# Next steps
if [[ $REQUIRED_MISSING -eq 0 ]]; then
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✓ Ready to Install!${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo "Run the installer:"
  echo ""
  echo "  curl -fsSL https://raw.githubusercontent.com/juvaraju-hub/AI-Playground/main/scripts/install.sh | bash"
  echo ""
  echo "Or clone and install manually:"
  echo ""
  echo "  git clone https://github.com/juvaraju-hub/AI-Playground.git"
  echo "  cd AI-Playground"
  echo "  # Follow INSTALL.md"
  echo ""
else
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${RED}⚠ Install Required Tools First${NC}"
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo "Install the missing required tools, then run this check again:"
  echo ""
  echo "  curl -fsSL https://raw.githubusercontent.com/juvaraju-hub/AI-Playground/main/scripts/check-prerequisites.sh | bash"
  echo ""
fi

exit $REQUIRED_MISSING
