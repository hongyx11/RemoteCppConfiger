#!/bin/bash
# Install Python CLI tools with uv.

set -euo pipefail

if ! command -v uv >/dev/null; then
  echo "ERROR: uv not found. Brewfile installs it; run 'brew bundle' first." >&2
  exit 1
fi

echo "==> uv tool install gita"
uv tool install --force gita

echo "    gita installed"
