#!/bin/sh

set -e

if [ "$CI" != "true" ]; then
  echo "Not running in CI, skipping changelog generation"
  exit 0
fi

go tool git-chglog --next-tag "$1" --output CHANGELOG.md

# Verify the changelog was generated
if [ ! -s CHANGELOG.md ]; then
    echo "Changelog generation failed or produced an empty file"
    exit 1
fi
