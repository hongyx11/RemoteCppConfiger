#!/bin/bash
# Install Python via uv and make it the default `python` / `python3` on PATH.
# Idempotent: re-running upgrades the patch version and re-pins.

set -euo pipefail

PYTHON_VERSION="${UV_PYTHON_VERSION:-3.13}"

if ! command -v uv >/dev/null; then
  echo "ERROR: uv not found. Brewfile installs it; run 'brew bundle' first." >&2
  exit 1
fi

echo "==> uv python install --default $PYTHON_VERSION"
uv python install --default "$PYTHON_VERSION"

echo "==> uv python pin --global $PYTHON_VERSION"
uv python pin --global "$PYTHON_VERSION"

echo "    $("$HOME/.local/bin/python" --version 2>&1)"
