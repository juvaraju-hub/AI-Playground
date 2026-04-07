#!/bin/bash
# Verify all MCP servers are configured properly

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "MCP Configuration Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if ~/.mcp.json exists
if [[ -f ~/.mcp.json ]]; then
  echo "✓ ~/.mcp.json file found"
  server_count=$(jq '.mcpServers | length' ~/.mcp.json 2>/dev/null || echo "0")
  echo "  → $server_count servers configured"
else
  echo "✗ ~/.mcp.json file not found"
  exit 1
fi

echo ""
echo "Configured MCP servers in ~/.mcp.json:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
jq -r '.mcpServers | keys[]' ~/.mcp.json 2>/dev/null | while read server; do
  type=$(jq -r ".mcpServers.\"$server\" | if .url then \"HTTP\" elif .command then \"STDIO\" else \"UNKNOWN\" end" ~/.mcp.json)
  echo "  • $server ($type)"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Checking MCP server health (via claude mcp list)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if command -v claude &> /dev/null; then
  claude mcp list
else
  echo "✗ claude command not found in PATH"
  exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Verification complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
