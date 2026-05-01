#!/bin/bash
# Render a managed shell-rc block for the given platform and shell.
# Usage: render.sh <linux|mac> <zsh|bash>
#
# Splices the contents of paths.<platform> into the {{PLATFORM_PATH_BLOCK}}
# placeholder in template.<shell>. Done in pure shell to avoid sed/awk
# replacement-string quoting hazards (brew shellenv output contains $ and ").

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <linux|mac> <zsh|bash>" >&2
  exit 64
fi

PLATFORM="$1"
SHELL_NAME="$2"
DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$DIR/template.$SHELL_NAME"
PATHS="$DIR/paths.$PLATFORM"

[ -f "$TEMPLATE" ] || { echo "missing template: $TEMPLATE" >&2; exit 1; }
[ -f "$PATHS" ]    || { echo "missing paths file: $PATHS" >&2; exit 1; }

while IFS= read -r line || [ -n "$line" ]; do
  if [ "$line" = "{{PLATFORM_PATH_BLOCK}}" ]; then
    cat "$PATHS"
  else
    printf '%s\n' "$line"
  fi
done < "$TEMPLATE"
