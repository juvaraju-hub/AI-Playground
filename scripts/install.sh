#!/usr/bin/env bash
# AI-Playground One-Line Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/juvaraju-hub/AI-Playground/main/scripts/install.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/juvaraju-hub/AI-Playground.git"
INSTALL_DIR="${AI_PLAYGROUND_INSTALL_DIR:-$HOME/ai-playground}"
BIN_DIR="${AI_PLAYGROUND_BIN_DIR:-$HOME/bin}"
SHELL_RC="${AI_PLAYGROUND_SHELL_RC:-}"

# Detect shell
if [[ -z "$SHELL_RC" ]]; then
  if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
  elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_RC="$HOME/.bashrc"
  else
    SHELL_RC="$HOME/.profile"
  fi
fi

# Helper functions
log() {
  echo -e "${BLUE}[installer]${NC} $*"
}

success() {
  echo -e "${GREEN}✓${NC} $*"
}

warn() {
  echo -e "${YELLOW}⚠${NC} $*"
}

error() {
  echo -e "${RED}✗${NC} $*"
  exit 1
}

prompt() {
  local message="$1"
  local default="$2"
  local response

  if [[ -n "$default" ]]; then
    read -p "$message [$default]: " response
    echo "${response:-$default}"
  else
    read -p "$message: " response
    echo "$response"
  fi
}

check_command() {
  local cmd="$1"
  if command -v "$cmd" &> /dev/null; then
    return 0
  else
    return 1
  fi
}

# Banner
cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              AI-Playground Installation Script                ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

EOF

log "Starting installation..."
echo ""

# Check prerequisites
log "Checking prerequisites..."

# Check Git
if ! check_command git; then
  error "Git is not installed. Please install Git first."
fi
success "Git found"

# Check Claude or Codex
HAS_CLAUDE=0
HAS_CODEX=0

if check_command claude; then
  HAS_CLAUDE=1
  success "Claude Code found"
fi

if check_command codex; then
  HAS_CODEX=1
  success "Codex found"
fi

if [[ $HAS_CLAUDE -eq 0 && $HAS_CODEX -eq 0 ]]; then
  error "Neither Claude Code nor Codex found. Please install at least one."
fi

# Check optional tools
echo ""
log "Checking optional tools..."

if check_command gh; then
  success "GitHub CLI found"
else
  warn "GitHub CLI not found (optional for MCP auth)"
fi

if check_command aws; then
  success "AWS CLI found"
else
  warn "AWS CLI not found (optional for cloud checks)"
fi

if check_command kubectl; then
  success "kubectl found"
else
  warn "kubectl not found (optional for K8s checks)"
fi

if check_command uv; then
  success "uv found"
else
  warn "uv not found (optional for Python MCP servers)"
fi

if check_command npx; then
  success "npx found"
else
  warn "npx not found (optional for NPX MCP servers)"
fi

echo ""
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "Installation Configuration"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Ask for installation directory
INSTALL_DIR=$(prompt "Installation directory" "$INSTALL_DIR")
BIN_DIR=$(prompt "Binary directory" "$BIN_DIR")

echo ""

# Clone repository
if [[ -d "$INSTALL_DIR" ]]; then
  log "Repository already exists at $INSTALL_DIR"
  log "Updating..."
  cd "$INSTALL_DIR"
  git pull origin main || error "Failed to update repository"
else
  log "Cloning repository to $INSTALL_DIR..."
  git clone "$REPO_URL" "$INSTALL_DIR" || error "Failed to clone repository"
  cd "$INSTALL_DIR"
fi

success "Repository ready at $INSTALL_DIR"
echo ""

# Create bin directory
mkdir -p "$BIN_DIR"

# Install tools
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "Installing Tools"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Install claude-start
if [[ $HAS_CLAUDE -eq 1 ]]; then
  log "Installing claude-start..."
  cd "$INSTALL_DIR/tools/claude-start"

  # Copy script
  cp claude-start "$BIN_DIR/claude-start"
  chmod +x "$BIN_DIR/claude-start"

  success "claude-start installed to $BIN_DIR/claude-start"
else
  warn "Skipping claude-start (Claude Code not found)"
fi

echo ""

# Install codex-start
if [[ $HAS_CODEX -eq 1 ]]; then
  log "Installing codex-start..."
  cd "$INSTALL_DIR/tools/codex-start"

  # Run install script
  bash install.sh || warn "codex-start installation had warnings"

  success "codex-start installed"
else
  warn "Skipping codex-start (Codex not found)"
fi

echo ""

# Check PATH
log "Checking PATH..."
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  warn "$BIN_DIR is not in PATH"

  # Add to shell config
  if ! grep -q "export PATH=\"$BIN_DIR:\$PATH\"" "$SHELL_RC" 2>/dev/null; then
    log "Adding $BIN_DIR to PATH in $SHELL_RC..."
    echo "" >> "$SHELL_RC"
    echo "# AI-Playground" >> "$SHELL_RC"
    echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$SHELL_RC"
    success "Added to $SHELL_RC"
    log "Run: source $SHELL_RC"
  fi
else
  success "$BIN_DIR is in PATH"
fi

echo ""

# MCP Setup
if [[ $HAS_CLAUDE -eq 1 ]]; then
  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  log "MCP Server Setup (Claude Code)"
  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  read -p "Do you want to set up MCP servers now? (y/N) " -n 1 -r
  echo ""

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd "$INSTALL_DIR/docs/mcp-setup"
    log "Running MCP registration script..."
    bash register-mcps.sh || warn "MCP registration had warnings"
  else
    log "Skipping MCP setup"
    log "To set up later, run:"
    log "  cd $INSTALL_DIR/docs/mcp-setup"
    log "  ./register-mcps.sh"
  fi

  echo ""
fi

# Shell Aliases
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "Shell Aliases"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Do you want to add shell aliases? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  log "Adding aliases to $SHELL_RC..."

  if ! grep -q "# AI-Playground aliases" "$SHELL_RC" 2>/dev/null; then
    cat >> "$SHELL_RC" << 'ALIASES'

# AI-Playground aliases
if command -v claude-start &> /dev/null; then
  alias ccx='claude-start'
  alias ccx-check='claude-start --check-only'
  alias ccx-mcp='claude-start --refresh-mcp'
fi

if command -v codex-start &> /dev/null; then
  alias cx='codex-start'
  alias cx-check='codex-start --check-only'
  alias cx-mcp='codex-start --refresh-mcp'
fi
ALIASES
    success "Aliases added to $SHELL_RC"
  else
    warn "Aliases already exist in $SHELL_RC"
  fi
else
  log "Skipping aliases"
fi

echo ""

# Summary
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "Installation Summary"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

success "Installation complete!"
echo ""

log "Installed to:"
log "  Repository: $INSTALL_DIR"
log "  Binaries:   $BIN_DIR"
log "  Shell RC:   $SHELL_RC"
echo ""

log "Installed tools:"
if [[ $HAS_CLAUDE -eq 1 ]]; then
  log "  ✓ claude-start"
fi
if [[ $HAS_CODEX -eq 1 ]]; then
  log "  ✓ codex-start"
fi
echo ""

log "Next steps:"
echo ""
log "1. Reload your shell:"
log "   source $SHELL_RC"
echo ""
log "2. Verify installation:"
if [[ $HAS_CLAUDE -eq 1 ]]; then
  log "   claude-start --help"
fi
if [[ $HAS_CODEX -eq 1 ]]; then
  log "   codex-start --help"
fi
echo ""
log "3. Run preflight checks:"
if [[ $HAS_CLAUDE -eq 1 ]]; then
  log "   claude-start --check-only"
fi
if [[ $HAS_CODEX -eq 1 ]]; then
  log "   codex-start --check-only"
fi
echo ""
log "4. For MCP OAuth setup (Claude Code):"
log "   claude-start --refresh-mcp"
echo ""

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "Documentation"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log "Full docs: $INSTALL_DIR/INSTALL.md"
log "MCP setup: $INSTALL_DIR/docs/mcp-setup/INDEX.md"
log "Quick ref: $INSTALL_DIR/docs/mcp-setup/QUICKSTART.txt"
echo ""

log "🎉 Happy coding!"
echo ""
