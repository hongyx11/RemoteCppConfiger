#!/bin/bash
# Install OpenCode into $PREFIX/bin and deploy saved user config when present.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
LIB="$PREFIX/lib"
mkdir -p "$BIN" "$LIB" "$PREFIX/cache"

export PATH="$BIN:$PATH"
export npm_config_cache="${npm_config_cache:-$PREFIX/cache/npm}"

install_opencode() {
  if [ -x "$BIN/opencode" ]; then
    echo "  opencode already installed, skipping."
    "$BIN/opencode" --version 2>/dev/null || true
    return
  fi
  if ! command -v npm >/dev/null; then
    echo "ERROR: npm missing; run install_node.sh first." >&2
    exit 1
  fi

  echo "==> opencode"
  local dest="$LIB/opencode-ai"
  mkdir -p "$dest"
  npm install --prefix "$dest" opencode-ai >/dev/null

  cat > "$BIN/opencode" <<WRAP
#!/bin/bash
exec "$dest/node_modules/.bin/opencode" "\$@"
WRAP
  chmod +x "$BIN/opencode"
  "$BIN/opencode" --version 2>/dev/null || true
}

deploy_opencode_config() {
  local deploy="$HOME/workspace/documents/myconfig/opencode/deploy-to-home.sh"
  if [ ! -x "$deploy" ]; then
    echo "  opencode config deploy script not found; skipping config deploy."
    return
  fi

  echo "==> opencode config"
  bash "$deploy"

  if [ -f "$HOME/.config/opencode/package.json" ]; then
    echo "==> opencode config dependencies"
    (cd "$HOME/.config/opencode" && npm install)
  fi
}

install_opencode
deploy_opencode_config

echo
echo "    opencode installed to $BIN/opencode"
