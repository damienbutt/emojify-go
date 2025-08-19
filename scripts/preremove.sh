#!/bin/bash
# Pre-removal script for emojify

# Remove symlink if it exists
if [ -L /usr/local/bin/emojify ]; then
    rm -f /usr/local/bin/emojify 2>/dev/null || true
fi

echo "Emojify has been removed."
