#!/bin/bash
# Source this file to add the install prefix to PATH.
# Default prefix is $HOME/local; override with PREFIX env var before sourcing.
#
# Usage:
#   source ~/.config/nvim/install_dependencies/setup_path.sh

_PREFIX="${PREFIX:-$HOME/local}"
case ":$PATH:" in
  *":$_PREFIX/bin:"*) ;;
  *) export PATH="$_PREFIX/bin:$PATH" ;;
esac
unset _PREFIX
