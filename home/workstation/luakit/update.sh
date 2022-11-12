#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#gawk nixpkgs#delta -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

awk -f update.awk default.nix > default.nix.new
delta --paging=never default.nix default.nix.new || true
mv default.nix.new default.nix
