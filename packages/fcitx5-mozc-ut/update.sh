#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=fcitx5-mozc-ut

utdicver_current=$(sed -n 's/.*utdicver = "\(.*\)";.*/\1/p' default.nix)
utdicver_latest=$(curl -sf "https://osdn.net/users/utuhiro/pf/utuhiro/files/?action=simple_list" | sed -n "s/.*mozcdic-ut-\(\w\+\).tar.bz2.*/\1/p")

if [[ $utdicver_current == $utdicver_latest ]]; then
    echo "$pname is up-to-date: $utdicver_latest"
    exit 0
fi

sed -i "s/utdicver = \"$utdicver_current\"/utdicver = \"$utdicver_latest\"/" default.nix
newhash=$(nix build "../..#${pname}" 2>&1 | sed -n "s/.*got:\s*\(.*\)/\1/p" || true)
sed -i "s|sha256 = \".*\"|sha256 = \"$newhash\"|" default.nix

echo "$pname updated: $utdicver_current -> $utdicver_latest"
