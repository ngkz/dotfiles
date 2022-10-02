#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=fcitx5-themes
owner=thep0y
repo=fcitx5-themes

current=$(nix eval --raw "../..#${pname}.rev")
commit=$(curl -sf https://api.github.com/repos/$owner/$repo/commits/main)
latest=$(jq -r .sha <<<"$commit")

if [[ $current == "$latest" ]]; then
    echo "$pname is up-to-date: $latest"
    exit 0
fi

sed -i "s|rev = \".*\"|rev = \"$latest\"|" default.nix
newhash=$(nix build "../..#${pname}" 2>&1 | sed -n "s/.*got:\s*\(.*\)/\1/p" || true)
sed -i "s|sha256 = \".*\"|sha256 = \"$newhash\"|" default.nix

echo "$pname updated: $current -> $latest"
