#!/bin/bash
# Install claude-start launcher script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${HOME}/bin"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installing claude-start launcher"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create ~/bin if it doesn't exist
if [[ ! -d "$INSTALL_DIR" ]]; then
  echo "Creating $INSTALL_DIR directory..."
  mkdir -p "$INSTALL_DIR"
fi

# Copy script
echo "Installing claude-start to $INSTALL_DIR/claude-start..."
cp "$SCRIPT_DIR/claude-start" "$INSTALL_DIR/claude-start"
chmod +x "$INSTALL_DIR/claude-start"

# Check if ~/bin is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  echo ""
  echo "⚠️  Warning: $INSTALL_DIR is not in your PATH"
  echo ""
  echo "Add this to your ~/.zshrc or ~/.bashrc:"
  echo "  export PATH=\"\$HOME/bin:\$PATH\""
  echo ""
fi

# Check if alias exists
if ! grep -q "alias ccx=" ~/.zshrc 2>/dev/null; then
  echo ""
  echo "Optional: Add alias to ~/.zshrc:"
  echo "  alias ccx='claude-start'"
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Installation complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Usage:"
echo "  claude-start                  # Run checks and launch Claude"
echo "  claude-start --refresh-mcp    # Validate and authenticate OAuth MCPs"
echo "  claude-start --check-only     # Check status without launching"
echo "  claude-start --help           # Show all options"
echo ""
echo "See documentation: docs/mcp-setup/SETUP_COMPLETE.md"
echo ""
