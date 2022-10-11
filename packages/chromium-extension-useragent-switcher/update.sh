#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl nixpkgs#nix-prefetch-github nixpkgs#jq -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=chromium-extension-useragent-switcher
owner=ray-lothian
repo=UserAgent-Switcher

current=$(nix eval --no-warn-dirty --raw "../..#${pname}.src.rev")
latest=$(curl -sf https://api.github.com/repos/$owner/$repo/commits/master | jq -r .sha)

if [[ $current == $latest ]]; then
    echo "$pname is up-to-date: $latest"
    exit 0
fi

version=$(curl -sf https://raw.githubusercontent.com/$owner/$repo/$latest/extension/chrome/manifest.json | jq -r ".version")
newhash=$(nix-prefetch-github --json "$owner" "$repo" --rev "$latest" | jq -r .sha256)
sed -i "s/version = \".*\"/version = \"$version\"/" default.nix
sed -i "s|rev = \".*\"|rev = \"$latest\"|" default.nix
sed -i "s|sha256 = \".*\"|sha256 = \"$newhash\"|" default.nix

echo "$pname updated: $current -> $latest ($version)"
