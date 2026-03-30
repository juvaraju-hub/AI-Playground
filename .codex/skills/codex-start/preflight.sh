#!/bin/bash
# Codex Start - Development Environment Preflight Checks
# Can be run standalone or via Codex skill

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
TERRAFORM_MCP_ENV="${HOME}/.config/codex/mcp-terraform.env"

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

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Codex Start - Preflight Checks${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${CYAN}📁 Repository Status${NC}"
if git rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git branch --show-current 2>&1)
  if [[ $? -eq 0 ]]; then
    echo -e "   ${GREEN}✓${NC} Branch: $branch"
    if [[ -n $(git status --short) ]]; then
      echo -e "   ${YELLOW}⚠${NC}  Uncommitted changes present:"
      git status --short | head -10 | sed 's/^/     /'
    else
      echo -e "   ${GREEN}✓${NC} Clean working tree"
    fi
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

if [[ "$REFRESH_MCP" == true ]]; then
  echo -e "${CYAN}🔄 MCP Server Connections${NC}"
  echo -e "   ${YELLOW}ℹ${NC}  MCP refresh requested"
  echo ""
  echo "   To refresh MCP servers:"
  echo "   1. In Codex, review MCP server status"
  echo "   2. Reconnect any disconnected servers"
  echo "   3. Complete any OAuth flows"
  echo ""
  echo "   Common servers:"
  echo "   • atlassian (Jira/Confluence)"
  echo "   • github (GitHub API)"
  echo "   • webexapis (Webex)"
  echo "   • terraform (Terraform Cloud)"
  echo ""
fi

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

echo -e "${CYAN}🐳 Container & Infrastructure${NC}"
check_tool "docker" "Docker" "brew install docker"
check_tool "terraform" "Terraform" "brew install terraform"
[[ "$SKIP_K8S" != true ]] && check_tool "kubectl" "Kubernetes CLI" "brew install kubectl"
echo ""

echo -e "${CYAN}🔀 Version Control & CI/CD${NC}"
check_tool "gh" "GitHub CLI" "brew install gh"
check_tool "codex" "Codex CLI"
echo ""

check_terraform_mcp() {
  echo -e "${CYAN}🔌 Terraform MCP${NC}"

  if ! command -v codex &> /dev/null; then
    echo -e "   ${YELLOW}⚠${NC}  Codex CLI not installed"
    echo -e "   ${YELLOW}💡${NC} Install Codex before configuring MCP servers"
    echo ""
    return 0
  fi

  local output
  if output=$(codex mcp get terraform 2>&1); then
    echo -e "   ${GREEN}✓${NC} Terraform MCP configured"
  else
    echo -e "   ${YELLOW}⚠${NC}  Terraform MCP not configured"
    echo -e "   ${YELLOW}💡${NC} Run: codex mcp add terraform -- uv run --env-file ~/.config/codex/mcp-terraform.env --directory /path/to/terraform-cloud-mcp terraform-cloud-mcp"
    echo ""
    return 0
  fi

  if [[ -f "$TERRAFORM_MCP_ENV" ]]; then
    echo -e "   ${GREEN}✓${NC} Env file present: $TERRAFORM_MCP_ENV"
    if grep -Eq '^READ_ONLY_TOOLS=true$' "$TERRAFORM_MCP_ENV"; then
      echo -e "   ${GREEN}✓${NC} READ_ONLY_TOOLS=true"
    else
      echo -e "   ${YELLOW}⚠${NC}  READ_ONLY_TOOLS should be true"
    fi
    if grep -Eq '^ENABLE_DELETE_TOOLS=false$' "$TERRAFORM_MCP_ENV"; then
      echo -e "   ${GREEN}✓${NC} ENABLE_DELETE_TOOLS=false"
    else
      echo -e "   ${YELLOW}⚠${NC}  ENABLE_DELETE_TOOLS should be false"
    fi
  else
    echo -e "   ${YELLOW}⚠${NC}  Env file missing: $TERRAFORM_MCP_ENV"
    echo -e "   ${YELLOW}💡${NC} Create it with TFC_TOKEN, TFC_ADDRESS, READ_ONLY_TOOLS=true, ENABLE_DELETE_TOOLS=false"
  fi

  echo ""
}

check_terraform_mcp

if [[ "$SKIP_AWS" != true ]]; then
  echo -e "${CYAN}☁️  AWS Environment${NC}"
  if command -v aws &> /dev/null; then
    aws_profile="${AWS_PROFILE:-default}"
    echo "   Profile: $aws_profile"
    aws_region=$(aws configure get region 2>&1 || echo "not-configured")
    echo "   Region: $aws_region"
    account_id=$(aws sts get-caller-identity --query Account --output text 2>&1)
    if [[ $? -eq 0 ]]; then
      echo "   Account: $account_id"
      identity=$(aws sts get-caller-identity --query Arn --output text 2>&1)
      echo "   Identity: ${identity:0:60}..."
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

if [[ "$SKIP_K8S" != true ]]; then
  echo -e "${CYAN}⎈  Kubernetes${NC}"
  if command -v kubectl &> /dev/null; then
    current_context=$(kubectl config current-context 2>&1)
    if [[ $? -eq 0 ]]; then
      echo "   Context: $current_context"
      if [[ $current_context =~ prod|production ]]; then
        echo -e "   ${RED}🔴 WARNING: PRODUCTION CONTEXT${NC}"
      fi
      namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>&1)
      if [[ -n "$namespace" ]]; then
        echo "   Namespace: $namespace"
      else
        echo "   Namespace: default"
      fi
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

if [[ "$FULL_CHECK" == true ]]; then
  echo -e "${CYAN}📋 Project Environment${NC}"
  if [[ -f "package.json" ]]; then
    echo -e "   ${GREEN}✓${NC} Node.js project detected"
    if [[ -d "node_modules" ]]; then
      echo -e "   ${GREEN}✓${NC} Dependencies installed"
    else
      echo -e "   ${YELLOW}⚠${NC}  Dependencies not installed"
      echo -e "   ${YELLOW}💡${NC} Run: npm install"
    fi
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
  if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
    echo -e "   ${GREEN}✓${NC} Python project detected"
    if [[ -d "venv" ]] || [[ -d ".venv" ]] || [[ -n "$VIRTUAL_ENV" ]]; then
      echo -e "   ${GREEN}✓${NC} Virtual environment active/found"
    else
      echo -e "   ${YELLOW}⚠${NC}  No virtual environment"
      echo -e "   ${YELLOW}💡${NC} Run: python -m venv venv && source venv/bin/activate"
    fi
  fi
  if [[ -f "go.mod" ]]; then
    echo -e "   ${GREEN}✓${NC} Go project detected"
    if command -v go &> /dev/null; then
      go version | sed 's/^/   /'
    fi
  fi
  if [[ -f "Cargo.toml" ]]; then
    echo -e "   ${GREEN}✓${NC} Rust project detected"
    if command -v cargo &> /dev/null; then
      cargo --version | sed 's/^/   /'
    fi
  fi
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
  if [[ -f ".env.example" ]] && [[ ! -f ".env" ]]; then
    echo -e "   ${YELLOW}⚠${NC}  .env file missing"
    echo -e "   ${YELLOW}💡${NC} Run: cp .env.example .env"
  fi
  echo ""
fi

if [[ -f ".codex-start.sh" ]]; then
  echo -e "${CYAN}🔍 Custom Project Checks${NC}"
  source .codex-start.sh
  echo ""
fi

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Preflight checks complete!${NC}"
echo ""
echo -e "${BLUE}💡 Quick Tips:${NC}"
echo "   • /codex-start --refresh-mcp     Refresh MCP connections"
echo "   • /codex-start --full            Run comprehensive checks"
echo "   • Create .codex-start.sh         Add custom project checks"
echo ""
echo -e "${BLUE}📚 Useful Commands:${NC}"
echo "   • git status                     Check repository status"
echo "   • codex mcp get terraform        Verify Terraform MCP"
echo "   • gh pr list                     List your pull requests"
echo "   • docker ps                      List running containers"
echo "   • kubectl get pods               List Kubernetes pods"
if [[ "$SKIP_AWS" != true ]]; then
  echo "   • aws sso login                  Refresh AWS credentials"
fi
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
