#!/bin/bash
# Install rustup + stable Rust toolchain into $PREFIX (default $HOME/local).
# Wrappers placed in $PREFIX/bin so RUSTUP_HOME / CARGO_HOME are auto-set.
# No shell rc edits required.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/local}"
BIN="$PREFIX/bin"
LIB="$PREFIX/lib"
mkdir -p "$BIN" "$LIB"

export RUSTUP_HOME="$LIB/rustup"
export CARGO_HOME="$LIB/cargo"

if [ -x "$CARGO_HOME/bin/cargo" ]; then
  echo "Rust already installed: $($CARGO_HOME/bin/cargo --version)"
else
  echo "==> Installing rustup → $RUSTUP_HOME"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --no-modify-path --default-toolchain stable --profile minimal
fi

# Set default toolchain (idempotent)
"$CARGO_HOME/bin/rustup" default stable >/dev/null

# Wrapper scripts in $BIN that auto-set RUSTUP_HOME/CARGO_HOME
for tool in cargo rustc rustup; do
  cat > "$BIN/$tool" <<WRAP
#!/bin/bash
export RUSTUP_HOME="\${RUSTUP_HOME:-$LIB/rustup}"
export CARGO_HOME="\${CARGO_HOME:-$LIB/cargo}"
exec "\$CARGO_HOME/bin/$tool" "\$@"
WRAP
  chmod +x "$BIN/$tool"
done

echo "    $($BIN/cargo --version)"
echo "    $($BIN/rustc --version)"
