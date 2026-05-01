#!/bin/bash
# Install atuin (shell history search) into $PREFIX/bin from a prebuilt release.
# No sudo. Atuin's database lives at $HOME/.local/share/atuin (created on first use).

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
SRC="$PREFIX/src"
mkdir -p "$BIN" "$SRC"

if [ -x "$BIN/atuin" ]; then
  echo "  atuin already installed, skipping."
  exit 0
fi

json=$(curl -fsSL "https://api.github.com/repos/atuinsh/atuin/releases/latest")
tag=""
if [[ "$json" =~ \"tag_name\":[[:space:]]*\"([^\"]+)\" ]]; then
  tag="${BASH_REMATCH[1]}"
fi
if [ -z "$tag" ]; then
  echo "ERROR: could not resolve atuin release tag." >&2
  exit 1
fi

stripped="${tag#v}"
url="https://github.com/atuinsh/atuin/releases/download/$tag/atuin-x86_64-unknown-linux-musl.tar.gz"

echo "==> atuin $tag"
cd "$SRC"
curl -fL --retry 3 -o atuin.tar.gz "$url"
rm -rf atuin-tmp
mkdir atuin-tmp
tar xf atuin.tar.gz -C atuin-tmp --strip-components=1
install -m755 atuin-tmp/atuin "$BIN/atuin"
rm -rf atuin.tar.gz atuin-tmp

echo "    $("$BIN/atuin" --version)"
