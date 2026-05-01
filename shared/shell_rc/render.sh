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

case "$PLATFORM" in
  linux|mac) ;;
  *) echo "error: unknown platform '$PLATFORM' (expected linux|mac)" >&2; exit 64 ;;
esac
case "$SHELL_NAME" in
  zsh|bash) ;;
  *) echo "error: unknown shell '$SHELL_NAME' (expected zsh|bash)" >&2; exit 64 ;;
esac

DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$DIR/template.$SHELL_NAME"
PATHS="$DIR/paths.$PLATFORM"

[ -f "$TEMPLATE" ] || { echo "missing template: $TEMPLATE" >&2; exit 1; }
[ -f "$PATHS" ]    || { echo "missing paths file: $PATHS" >&2; exit 1; }

placeholder_hit=0
while IFS= read -r line || [ -n "$line" ]; do
  if [ "$line" = "{{PLATFORM_PATH_BLOCK}}" ]; then
    placeholder_hit=1
    cat "$PATHS"
  else
    printf '%s\n' "$line"
  fi
done < "$TEMPLATE"

if [ "$placeholder_hit" -eq 0 ]; then
  echo "error: {{PLATFORM_PATH_BLOCK}} not found in $TEMPLATE" >&2
  exit 1
fi
