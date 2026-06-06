#!/bin/bash
# Install LSP servers into $PREFIX (default $HOME/local).
#   pyright, html/css, yaml,
#   bash                    → npm into $PREFIX/lib, wrapped in $PREFIX/bin
#   lua-language-server     → prebuilt tarball
#   neocmakelsp             → cargo install into $PREFIX

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
LIB="$PREFIX/lib"
SRC="$PREFIX/src"
mkdir -p "$BIN" "$LIB" "$SRC" "$PREFIX/cache"

export PATH="$BIN:$PATH"
export npm_config_cache="${npm_config_cache:-$PREFIX/cache/npm}"

# ── pyright ───────────────────────────────────────────
install_pyright() {
  if [ -x "$BIN/pyright-langserver" ]; then
    echo "  pyright already installed, skipping."; return
  fi
  if ! command -v npm >/dev/null; then
    echo "  npm missing — run install_node.sh first. Skipping pyright."
    return 1
  fi
  echo "==> pyright"
  local dest="$LIB/pyright"
  mkdir -p "$dest"
  npm install --prefix "$dest" pyright >/dev/null 2>&1

  cat > "$BIN/pyright" <<WRAP
#!/bin/bash
exec "$dest/node_modules/.bin/pyright" "\$@"
WRAP
  cat > "$BIN/pyright-langserver" <<WRAP
#!/bin/bash
exec "$dest/node_modules/.bin/pyright-langserver" "\$@"
WRAP
  chmod +x "$BIN/pyright" "$BIN/pyright-langserver"
}

# ── html/css LSP (vscode-langservers-extracted) ───────
install_vscode_langservers() {
  if [ -x "$BIN/vscode-html-language-server" ]; then
    echo "  html/css LSPs already installed, skipping."; return
  fi
  if ! command -v npm >/dev/null; then
    echo "  npm missing — skipping html/css LSP."
    return 1
  fi
  echo "==> html/css LSP (vscode-langservers-extracted)"
  local dest="$LIB/vscode-langservers"
  mkdir -p "$dest"
  npm install --prefix "$dest" vscode-langservers-extracted >/dev/null 2>&1

  for cmd in vscode-html-language-server vscode-css-language-server \
             vscode-json-language-server vscode-eslint-language-server; do
    if [ -e "$dest/node_modules/.bin/$cmd" ]; then
      cat > "$BIN/$cmd" <<WRAP
#!/bin/bash
exec "$dest/node_modules/.bin/$cmd" "\$@"
WRAP
      chmod +x "$BIN/$cmd"
    fi
  done
}

# ── yaml/bash LSPs ────────────────────────────────────
install_node_lsp_servers() {
  if [ -x "$BIN/bash-language-server" ] && [ -x "$BIN/yaml-language-server" ]; then
    echo "  yaml/bash LSPs already installed, skipping."; return
  fi
  if ! command -v npm >/dev/null; then
    echo "  npm missing — skipping yaml/bash LSPs."
    return 1
  fi
  echo "==> yaml/bash LSPs"
  local dest="$LIB/node-lsp-servers"
  mkdir -p "$dest"
  npm install --prefix "$dest" bash-language-server yaml-language-server >/dev/null 2>&1

  for cmd in bash-language-server yaml-language-server; do
    if [ -e "$dest/node_modules/.bin/$cmd" ]; then
      cat > "$BIN/$cmd" <<WRAP
#!/bin/bash
exec "$dest/node_modules/.bin/$cmd" "\$@"
WRAP
      chmod +x "$BIN/$cmd"
    fi
  done
}

# ── lua-language-server (prebuilt) ────────────────────
install_lua_ls() {
  if [ -x "$BIN/lua-language-server" ] && [ -x "$LIB/lua-language-server/bin/lua-language-server" ]; then
    echo "  lua-language-server already installed, skipping."; return
  fi
  echo "==> lua-language-server (prebuilt)"
  local tag json
  json=$(curl -fsSL "https://api.github.com/repos/LuaLS/lua-language-server/releases/latest")
  tag=""
  if [[ "$json" =~ \"tag_name\":[[:space:]]*\"([^\"]+)\" ]]; then
    tag="${BASH_REMATCH[1]}"
  fi
  local stripped="${tag#v}"
  local url="https://github.com/LuaLS/lua-language-server/releases/download/$tag/lua-language-server-${stripped}-linux-x64.tar.gz"
  local dest="$LIB/lua-language-server"

  rm -rf "$dest"
  mkdir -p "$dest"
  cd "$SRC"
  curl -fL -o lua-ls.tar.gz "$url"
  tar xf lua-ls.tar.gz -C "$dest"
  rm -f lua-ls.tar.gz

  cat > "$BIN/lua-language-server" <<WRAP
#!/bin/bash
exec "$dest/bin/lua-language-server" "\$@"
WRAP
  chmod +x "$BIN/lua-language-server"
}

# ── neocmakelsp (cargo) ───────────────────────────────
install_neocmakelsp() {
  if [ -x "$BIN/neocmakelsp" ]; then
    echo "  neocmakelsp already installed, skipping."; return
  fi
  if ! command -v cargo >/dev/null; then
    echo "  cargo missing — run install_rust.sh first. Skipping neocmakelsp."
    return 1
  fi
  echo "==> neocmakelsp"
  cargo install neocmakelsp --root "$PREFIX" --locked >/dev/null 2>&1
}

install_pyright             || true
install_vscode_langservers  || true
install_node_lsp_servers    || true
install_lua_ls
install_neocmakelsp         || true

echo
echo "    LSP servers installed to $BIN"
