#!/bin/bash
# Install/deploy OpenCode user config on macOS.

set -euo pipefail

if ! command -v opencode >/dev/null; then
  echo "ERROR: opencode not found. Brewfile should install anomalyco/tap/opencode." >&2
  exit 1
fi

echo "==> opencode"
opencode --version 2>/dev/null || true

DEPLOY="$HOME/workspace/documents/myconfig/opencode/deploy-to-home.sh"
if [ -x "$DEPLOY" ]; then
  echo "==> opencode config"
  bash "$DEPLOY"
else
  echo "  opencode config deploy script not found; skipping config deploy."
fi

if [ -f "$HOME/.config/opencode/package.json" ]; then
  if ! command -v npm >/dev/null; then
    echo "  npm missing; skipping opencode config dependencies."
  else
    echo "==> opencode config dependencies"
    (cd "$HOME/.config/opencode" && npm install)
  fi
fi
