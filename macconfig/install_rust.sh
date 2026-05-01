#!/bin/bash
# Bootstrap rust on mac via brew's rustup-init.
# PATH for ~/.cargo/bin is added by setup_shell_rc.sh, so we don't modify PATH here.

set -euo pipefail

if [ -x "$HOME/.cargo/bin/rustc" ]; then
  echo "  rustc already installed at $HOME/.cargo/bin/rustc, skipping."
  "$HOME/.cargo/bin/rustc" --version
  exit 0
fi

if ! command -v rustup-init >/dev/null 2>&1; then
  echo "  rustup-init not found — make sure 'brew install rustup' has run."
  exit 1
fi

echo "==> Running rustup-init -y --no-modify-path"
rustup-init -y --no-modify-path
"$HOME/.cargo/bin/rustc" --version
