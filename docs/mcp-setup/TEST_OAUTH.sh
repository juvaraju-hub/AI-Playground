#!/bin/bash
# Test OAuth flow without launching Claude

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Testing OAuth MCP Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will check MCP server status and show which ones need auth"
echo ""

# Run claude-start with check-only and refresh-mcp
~/bin/claude-start --check-only --refresh-mcp

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "To authenticate servers, run:"
echo "  claude-start --refresh-mcp"
echo ""
echo "Or to authenticate without prompts:"
echo "  claude-start --refresh-mcp --yes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
