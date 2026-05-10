#!/bin/bash
# Install Google Gemini CLI (@google/gemini-cli) into $PREFIX (default $HOME/local).
# Sandboxed under $LIB/gemini with a wrapper in $BIN — avoids polluting global npm.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
LIB="$PREFIX/lib"
mkdir -p "$BIN" "$LIB" "$PREFIX/cache"

export PATH="$BIN:$PATH"
export npm_config_cache="${npm_config_cache:-$PREFIX/cache/npm}"

if [ -x "$BIN/gemini" ]; then
  echo "  gemini already installed, skipping."
  exit 0
fi

if ! command -v npm >/dev/null; then
  echo "  npm missing — run install_node.sh first. Skipping gemini."
  exit 1
fi

echo "==> gemini (@google/gemini-cli)"
dest="$LIB/gemini"
mkdir -p "$dest"
npm install --prefix "$dest" @google/gemini-cli >/dev/null 2>&1

cat > "$BIN/gemini" <<WRAP
#!/bin/bash
exec "$dest/node_modules/.bin/gemini" "\$@"
WRAP
chmod +x "$BIN/gemini"

echo "    gemini installed to $BIN/gemini"
