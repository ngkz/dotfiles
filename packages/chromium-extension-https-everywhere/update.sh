#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl nixpkgs#nodePackages.node2nix nixpkgs#nix-prefetch-github nixpkgs#jq -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=chromium-extension-https-everywhere
owner=EFForg
repo=https-everywhere

current=$(nix eval --raw "../..#${pname}.version")
latest=$(curl -s "https://api.github.com/repos/$owner/$repo/releases/latest" | jq -r ".tag_name")

if [[ $current == $latest ]]; then
    echo "$pname is up-to-date: $latest"
    exit 0
fi

sed -i "s/version = \"$current\"/version = \"$latest\"/" default.nix
newhash=$(nix-prefetch-github --json "$owner" "$repo" --rev "$latest" --fetch-submodules | jq -r .sha256)
sed -i "s|sha256 = \".*\"|sha256 = \"$newhash\"|" default.nix

echo "$pname updated: $current -> $latest"
