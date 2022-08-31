#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl nixpkgs#nix-prefetch-github nixpkgs#jq -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=networkmanager_dmenu
owner=firecat53
repo=networkmanager-dmenu

current=$(nix eval --raw "../..#${pname}.src.rev")
latest=$(curl -s https://api.github.com/repos/$owner/$repo/commits/main | jq -r .sha)

if [[ $current == $latest ]]; then
    echo "$pname is up-to-date: $latest"
    exit 0
fi

release=$(curl -s "https://api.github.com/repos/$owner/$repo/releases/latest" | jq -r ".tag_name" | cut -c2-)
newhash=$(nix-prefetch-github --json "$owner" "$repo" --rev "$latest" | jq -r .sha256)
sed -i "s/release = \".*\"/release = \"$release\"/" default.nix
sed -i "s|rev = \".*\"|rev = \"$latest\"|" default.nix
sed -i "s|sha256 = \".*\"|sha256 = \"$newhash\"|" default.nix

echo "$pname updated: $current -> $latest ($release)"
