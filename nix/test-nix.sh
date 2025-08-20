#!/usr/bin/env bash

# Example script showing how to use emojify-go with Nix

set -euo pipefail

echo "🧪 Testing emojify-go Nix installation..."

if command -v nix >/dev/null 2>&1; then
    echo "✅ Nix is installed"

    if nix --version | grep -q "flake"; then
        echo "✅ Nix flakes are supported"
        echo ""
        echo "🚀 You can install emojify-go with:"
        echo "   nix profile install github:damienbutt/emojify-go"
        echo ""
        echo "🧑‍💻 Or enter development environment with:"
        echo "   nix develop"
        echo ""
        echo "⚡ Or run directly without installing:"
        echo "   nix run github:damienbutt/emojify-go -- 'Hello :wave: world'"
    else
        echo "ℹ️  Nix flakes not detected, using traditional Nix"
        echo ""
        echo "🚀 You can install emojify-go with:"
        echo "   nix-env -f default.nix -i emojify-go"
        echo ""
        echo "🧑‍💻 Or enter development environment with:"
        echo "   nix-shell"
    fi
else
    echo "❌ Nix is not installed"
    echo ""
    echo "📥 Install Nix:"
    echo "   curl -L https://nixos.org/nix/install | sh"
    echo ""
    echo "🔄 Then reload your shell and run this script again"
fi

echo ""
echo "📚 For more information, see:"
echo "   - ./nix/README.md"
echo "   - https://github.com/damienbutt/emojify-go#-nixos--nix"
