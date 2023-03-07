#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl nixpkgs#nix-prefetch-github nixpkgs#jq -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=fcitx5-skk
owner=fcitx
repo=$pname

current=$(nix eval --no-warn-dirty --raw "../..#${pname}.version")
latest=$(curl -sf "https://api.github.com/repos/$owner/$repo/tags" | jq -r ".[0].name")

if [[ $current == $latest ]]; then
    echo "$pname is up-to-date: $latest"
    exit 0
fi

sed -i "s/version = \"$current\"/version = \"$latest\"/" default.nix
newhash=$(nix-prefetch-github --json "$owner" "$repo" --rev "$latest" | jq -r .sha256)
sed -i "s|sha256 = \".*\"|sha256 = \"$newhash\"|" default.nix

echo "$pname updated: $current -> $latest"
