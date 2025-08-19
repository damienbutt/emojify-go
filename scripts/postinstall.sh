#!/bin/bash
# Post-installation script for emojify

# Create symlink if needed (for compatibility)
if [ ! -L /usr/local/bin/emojify ] && [ -f /usr/bin/emojify ]; then
    ln -sf /usr/bin/emojify /usr/local/bin/emojify 2>/dev/null || true
fi

# Print installation message
echo "✅ Emojify installed successfully!"
echo "Run 'emojify --help' to get started."
echo "Examples:"
echo "  echo 'Hello :wave: world' | emojify"
echo "  emojify 'Deploy completed :rocket:'"
