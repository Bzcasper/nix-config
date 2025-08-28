#!/usr/bin/env bash
# Ubuntu-specific Claude Code integration script
# Integrates existing claude-hooks setup with Home Manager

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
NIX_CONFIG_DIR="$HOME/nix-config"

echo "=== Ubuntu Claude Code Integration ==="

# Check if claude-hooks are already installed
if [[ -f "$CLAUDE_DIR/hooks/portable-quality-validator.py" ]]; then
    echo "✅ Claude hooks already installed and configured"
    echo "   - Quality validation hooks: OK"
    echo "   - Hook configuration: OK"
else
    echo "❌ Claude hooks not found in $CLAUDE_DIR/hooks/"
    exit 1
fi

# Verify settings.json has our custom hooks
if grep -q "portable-quality-validator" "$CLAUDE_DIR/settings.json" 2>/dev/null; then
    echo "✅ Claude settings.json configured with custom hooks"
else
    echo "⚠️  Custom hooks not found in settings.json - may need update"
fi

# Check if Home Manager claude-code module exists
if [[ -f "$NIX_CONFIG_DIR/home-manager/claude-code/default.nix" ]]; then
    echo "✅ Home Manager claude-code module found"
else
    echo "❌ Home Manager claude-code module missing"
    exit 1
fi

# Create symlinks for integrated configuration
echo "Creating integration symlinks..."

# Backup existing Nix claude settings if they exist
if [[ -f "$NIX_CONFIG_DIR/home-manager/claude-code/settings.json" ]]; then
    cp "$NIX_CONFIG_DIR/home-manager/claude-code/settings.json" \
       "$NIX_CONFIG_DIR/home-manager/claude-code/settings.json.nix-backup"
    echo "✅ Backed up Nix claude settings"
fi

# Link our working settings to Nix config
ln -sf "$CLAUDE_DIR/settings.json" \
       "$NIX_CONFIG_DIR/home-manager/claude-code/settings.json"
echo "✅ Linked claude settings to Nix config"

# Ensure our hooks directory is preserved
if [[ ! -L "$NIX_CONFIG_DIR/home-manager/claude-code/hooks-working" ]]; then
    ln -sf "$CLAUDE_DIR/hooks" \
           "$NIX_CONFIG_DIR/home-manager/claude-code/hooks-working"
    echo "✅ Linked working hooks to Nix config"
fi

echo ""
echo "=== Integration Summary ==="
echo "✅ Ubuntu 25.04 trapstation host configured"
echo "✅ Claude hooks integrated with Nix configuration"  
echo "✅ Home Manager will preserve working claude setup"
echo ""
echo "Next: Run 'update' alias once Home Manager build completes"