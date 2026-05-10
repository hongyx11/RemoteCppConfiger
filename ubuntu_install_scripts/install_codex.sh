#!/bin/bash
# Install OpenAI Codex CLI (@openai/codex) into $PREFIX (default $HOME/local).
# Sandboxed under $LIB/codex with a wrapper in $BIN — avoids polluting global npm.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
LIB="$PREFIX/lib"
mkdir -p "$BIN" "$LIB" "$PREFIX/cache"

export PATH="$BIN:$PATH"
export npm_config_cache="${npm_config_cache:-$PREFIX/cache/npm}"

if [ -x "$BIN/codex" ]; then
  echo "  codex already installed, skipping."
  exit 0
fi

if ! command -v npm >/dev/null; then
  echo "  npm missing — run install_node.sh first. Skipping codex."
  exit 1
fi

echo "==> codex (@openai/codex)"
dest="$LIB/codex"
mkdir -p "$dest"
npm install --prefix "$dest" @openai/codex >/dev/null 2>&1

cat > "$BIN/codex" <<WRAP
#!/bin/bash
exec "$dest/node_modules/.bin/codex" "\$@"
WRAP
chmod +x "$BIN/codex"

echo "    codex installed to $BIN/codex"
