#!/bin/bash
# Claude Start - Development Environment Preflight Checks
# Can be run standalone or via Claude Code skill

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse arguments
REFRESH_MCP=false
FULL_CHECK=false
SKIP_AWS=false
SKIP_K8S=false

for arg in "$@"; do
  case $arg in
    --refresh-mcp) REFRESH_MCP=true ;;
    --full) FULL_CHECK=true ;;
    --skip-aws) SKIP_AWS=true ;;
    --skip-k8s) SKIP_K8S=true ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --refresh-mcp    Refresh MCP server connections"
      echo "  --full           Run comprehensive checks"
      echo "  --skip-aws       Skip AWS environment checks"
      echo "  --skip-k8s       Skip Kubernetes checks"
      echo "  --help           Show this help message"
      exit 0
      ;;
  esac
done

# Banner
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Claude Start - Preflight Checks${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 1. Repository Check
echo -e "${CYAN}📁 Repository Status${NC}"
if git rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git branch --show-current 2>&1)
  if [[ $? -eq 0 ]]; then
    echo -e "   ${GREEN}✓${NC} Branch: $branch"

    # Check for uncommitted changes
    if [[ -n $(git status --short) ]]; then
      echo -e "   ${YELLOW}⚠${NC}  Uncommitted changes present:"
      git status --short | head -10 | sed 's/^/     /'
    else
      echo -e "   ${GREEN}✓${NC} Clean working tree"
    fi

    # Show recent commits
    if [[ "$FULL_CHECK" == true ]]; then
      echo -e "   Recent commits:"
      git log --oneline -5 | sed 's/^/     /'
    fi
  fi
else
  echo -e "   ${YELLOW}⚠${NC}  Not a git repository"
  echo -e "   Current directory: $(pwd)"
fi
echo ""

# 2. MCP Server Refresh
if [[ "$REFRESH_MCP" == true ]]; then
  echo -e "${CYAN}🔄 MCP Server Connections${NC}"
  echo -e "   ${YELLOW}ℹ${NC}  MCP refresh requested"
  echo ""
  echo "   To refresh MCP servers:"
  echo "   1. In Claude Code, type: ${BLUE}/mcp${NC}"
  echo "   2. Select 'Reconnect' for each server"
  echo "   3. Complete any OAuth flows"
  echo ""
  echo "   Common servers:"
  echo "   • atlassian (Jira/Confluence)"
  echo "   • github (GitHub API)"
  echo "   • slack (Team messaging)"
  echo "   • webexapis (Webex)"
  echo ""
fi

# 3. Core Tools Check
echo -e "${CYAN}🔧 Core Development Tools${NC}"

check_tool() {
  local cmd=$1
  local name=$2
  local install_hint=$3

  if command -v "$cmd" &> /dev/null; then
    version=$($cmd --version 2>&1 | head -1 | cut -c 1-60)
    echo -e "   ${GREEN}✓${NC} $name: $version"
    return 0
  else
    echo -e "   ${RED}✗${NC} $name: Not installed"
    [[ -n "$install_hint" ]] && echo -e "      ${YELLOW}💡${NC} $install_hint"
    return 1
  fi
}

check_tool "git" "Git" "brew install git"
check_tool "curl" "cURL"
check_tool "jq" "JSON Processor" "brew install jq"

# Language runtimes
if [[ "$FULL_CHECK" == true ]]; then
  echo ""
  echo -e "${CYAN}📦 Language Runtimes${NC}"
  check_tool "node" "Node.js" "brew install node"
  check_tool "npm" "npm"
  check_tool "python3" "Python" "brew install python"
  check_tool "pip3" "pip"
  check_tool "go" "Go" "brew install go"
  check_tool "cargo" "Rust" "brew install rust"
  check_tool "java" "Java" "brew install openjdk"
fi
echo ""

# 4. Container & Infrastructure Tools
echo -e "${CYAN}🐳 Container & Infrastructure${NC}"
check_tool "docker" "Docker" "brew install docker"
check_tool "terraform" "Terraform" "brew install terraform"
[[ "$SKIP_K8S" != true ]] && check_tool "kubectl" "Kubernetes CLI" "brew install kubectl"
echo ""

# 5. Version Control & CI/CD Tools
echo -e "${CYAN}🔀 Version Control & CI/CD${NC}"
check_tool "gh" "GitHub CLI" "brew install gh"
echo ""

# 6. AWS Environment Check
if [[ "$SKIP_AWS" != true ]]; then
  echo -e "${CYAN}☁️  AWS Environment${NC}"

  if command -v aws &> /dev/null; then
    # Get current profile
    aws_profile="${AWS_PROFILE:-default}"
    echo "   Profile: $aws_profile"

    # Get current region
    aws_region=$(aws configure get region 2>&1 || echo "not-configured")
    echo "   Region: $aws_region"

    # Get account ID
    account_id=$(aws sts get-caller-identity --query Account --output text 2>&1)
    if [[ $? -eq 0 ]]; then
      echo "   Account: $account_id"

      # Get identity ARN
      identity=$(aws sts get-caller-identity --query Arn --output text 2>&1)
      echo "   Identity: ${identity:0:60}..."

      # Check if production (customize account IDs for your org)
      if [[ "$account_id" =~ ^(739084098447|987654321098)$ ]]; then
        echo -e "   ${RED}🔴 WARNING: PRODUCTION ACCOUNT${NC}"
      fi
    else
      echo -e "   ${YELLOW}⚠${NC}  AWS credentials not configured or expired"
      echo -e "   ${YELLOW}💡${NC} Run: aws configure"
      echo -e "   ${YELLOW}💡${NC} Or: aws sso login"
    fi
  else
    echo -e "   ${YELLOW}⚠${NC}  AWS CLI not installed"
    echo -e "   ${YELLOW}💡${NC} Run: brew install awscli"
  fi
  echo ""
fi

# 7. Kubernetes Context Check
if [[ "$SKIP_K8S" != true ]]; then
  echo -e "${CYAN}⎈  Kubernetes${NC}"

  if command -v kubectl &> /dev/null; then
    current_context=$(kubectl config current-context 2>&1)
    if [[ $? -eq 0 ]]; then
      echo "   Context: $current_context"

      # Production warning
      if [[ $current_context =~ prod|production ]]; then
        echo -e "   ${RED}🔴 WARNING: PRODUCTION CONTEXT${NC}"
      fi

      # Current namespace
      namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>&1)
      if [[ -n "$namespace" ]]; then
        echo "   Namespace: $namespace"
      else
        echo "   Namespace: default"
      fi

      # Show available contexts
      if [[ "$FULL_CHECK" == true ]]; then
        echo -e "   Available contexts:"
        kubectl config get-contexts -o name | head -5 | sed 's/^/     • /'
      fi
    else
      echo -e "   ${YELLOW}⚠${NC}  No kubernetes context configured"
      echo -e "   ${YELLOW}💡${NC} Run: kubectl config use-context <context-name>"
    fi
  else
    echo -e "   ${YELLOW}⚠${NC}  kubectl not installed"
  fi
  echo ""
fi

# 8. Language-Specific Project Checks
if [[ "$FULL_CHECK" == true ]]; then
  echo -e "${CYAN}📋 Project Environment${NC}"

  # Node.js
  if [[ -f "package.json" ]]; then
    echo -e "   ${GREEN}✓${NC} Node.js project detected"
    if [[ -d "node_modules" ]]; then
      echo -e "   ${GREEN}✓${NC} Dependencies installed"
    else
      echo -e "   ${YELLOW}⚠${NC}  Dependencies not installed"
      echo -e "   ${YELLOW}💡${NC} Run: npm install"
    fi

    # Check for .nvmrc
    if [[ -f ".nvmrc" ]]; then
      required=$(cat .nvmrc)
      if command -v node &> /dev/null; then
        current=$(node --version)
        if [[ "$current" != "$required" ]]; then
          echo -e "   ${YELLOW}⚠${NC}  Node version mismatch (required: $required, current: $current)"
          echo -e "   ${YELLOW}💡${NC} Run: nvm use"
        fi
      fi
    fi
  fi

  # Python
  if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
    echo -e "   ${GREEN}✓${NC} Python project detected"
    if [[ -d "venv" ]] || [[ -d ".venv" ]] || [[ -n "$VIRTUAL_ENV" ]]; then
      echo -e "   ${GREEN}✓${NC} Virtual environment active/found"
    else
      echo -e "   ${YELLOW}⚠${NC}  No virtual environment"
      echo -e "   ${YELLOW}💡${NC} Run: python -m venv venv && source venv/bin/activate"
    fi
  fi

  # Go
  if [[ -f "go.mod" ]]; then
    echo -e "   ${GREEN}✓${NC} Go project detected"
    if command -v go &> /dev/null; then
      go version | sed 's/^/   /'
    fi
  fi

  # Rust
  if [[ -f "Cargo.toml" ]]; then
    echo -e "   ${GREEN}✓${NC} Rust project detected"
    if command -v cargo &> /dev/null; then
      cargo --version | sed 's/^/   /'
    fi
  fi

  # Docker Compose
  if [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]]; then
    echo -e "   ${GREEN}✓${NC} Docker Compose project detected"
    if command -v docker &> /dev/null; then
      running=$(docker compose ps -q 2>/dev/null | wc -l | tr -d ' ')
      if [[ "$running" -gt 0 ]]; then
        echo -e "   ${GREEN}✓${NC} $running container(s) running"
      else
        echo -e "   ${YELLOW}⚠${NC}  No containers running"
        echo -e "   ${YELLOW}💡${NC} Run: docker compose up -d"
      fi
    fi
  fi

  # .env file check
  if [[ -f ".env.example" ]] && [[ ! -f ".env" ]]; then
    echo -e "   ${YELLOW}⚠${NC}  .env file missing"
    echo -e "   ${YELLOW}💡${NC} Run: cp .env.example .env"
  fi

  echo ""
fi

# 9. Run custom local checks if present
if [[ -f ".claude-start.sh" ]]; then
  echo -e "${CYAN}🔍 Custom Project Checks${NC}"
  source .claude-start.sh
  echo ""
fi

# 10. Summary
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Preflight checks complete!${NC}"
echo ""
echo -e "${BLUE}💡 Quick Tips:${NC}"
echo "   • /claude-start --refresh-mcp    Refresh MCP connections"
echo "   • /claude-start --full           Run comprehensive checks"
echo "   • Create .claude-start.sh        Add custom project checks"
echo ""
echo -e "${BLUE}📚 Useful Commands:${NC}"
echo "   • git status                     Check repository status"
echo "   • gh pr list                     List your pull requests"
echo "   • docker ps                      List running containers"
echo "   • kubectl get pods               List Kubernetes pods"
if [[ "$SKIP_AWS" != true ]]; then
  echo "   • aws sso login                  Refresh AWS credentials"
fi
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
