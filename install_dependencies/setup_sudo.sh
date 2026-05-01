#!/bin/bash
# Sudo-required setup for RemoteCppConfiger.
# Run as:    sudo bash ~/setup_sudo.sh
# Or:        bash ~/setup_sudo.sh   (it will re-exec under sudo)

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  exec sudo -E bash "$0" "$@"
fi

echo "==> apt update"
apt-get update

echo "==> Installing gcc-12 / g++-12 (RemoteCppConfiger Stage 1, sudo path)"
apt-get install -y gcc-12 g++-12

echo
echo "Done. Versions:"
gcc-12 --version | head -1
g++-12 --version | head -1
