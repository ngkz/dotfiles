#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=chromium-extension-keepassxc-browser
owner=keepassxreboot
repo=keepassxc-browser

current=$(nix eval --no-warn-dirty --raw "../..#${pname}.version")
latest=$(curl -sf "https://api.github.com/repos/$owner/$repo/releases/latest" | jq -r ".tag_name")

if [[ $current == $latest ]]; then
    echo "$pname is up-to-date: $latest"
    exit 0
fi

sed -i "s/version = \"$current\"/version = \"$latest\"/" default.nix
url=$(nix eval --no-warn-dirty --raw "../..#${pname}.src.urls" --apply builtins.head)
newhash=$(nix-prefetch-url "$url" --unpack)
sed -i "s|sha256 = \".*\"|sha256 = \"$newhash\"|" default.nix

echo "$pname updated: $current -> $latest"
