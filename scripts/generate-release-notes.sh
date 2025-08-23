#!/bin/sh

set -e

if [ "$CI" != "true" ]; then
  echo "Not running in CI, skipping release notes generation"
  exit 0
fi

go tool git-chglog --next-tag "$1" "$1" --output RELEASE_NOTES.md
