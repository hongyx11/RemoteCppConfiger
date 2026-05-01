#!/bin/bash
# Install just (command runner) into $PREFIX/bin.
# Uses the official prebuilt binary from GitHub releases. No sudo.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
mkdir -p "$BIN"
export PATH="$BIN:$PATH"

if [ -x "$BIN/just" ]; then
  echo "  just already installed, skipping."
  echo "    $("$BIN/just" --version)"
  exit 0
fi

echo "==> Installing just → $BIN"
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh \
  | bash -s -- --to "$BIN"

echo "    $("$BIN/just" --version)"
