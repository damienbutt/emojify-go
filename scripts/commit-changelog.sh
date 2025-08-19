#!/bin/bash

# Script to commit updated CHANGELOG.md after GoReleaser runs
# Usage: ./scripts/commit-changelog.sh <tag>

set -e

TAG="${1}"
if [[ -z "$TAG" ]]; then
    echo "Usage: $0 <tag>"
    echo "Example: $0 v0.6.0"
    exit 1
fi

# Check if CHANGELOG.md has changes
if [[ -n "$(git status --porcelain CHANGELOG.md)" ]]; then
    echo "📝 Committing updated CHANGELOG.md for $TAG"
    git add CHANGELOG.md
    git commit -m "chore: update CHANGELOG.md for $TAG [skip ci]"

    # Push to the current branch (usually master/main)
    CURRENT_BRANCH=$(git branch --show-current)
    git push origin HEAD:"$CURRENT_BRANCH"

    echo "✅ CHANGELOG.md committed and pushed to $CURRENT_BRANCH"
else
    echo "ℹ️  No changes to CHANGELOG.md to commit"
fi
