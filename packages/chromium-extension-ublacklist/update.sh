#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

owner=iorate
repo=ublacklist
pname=chromium-extension-$repo

current=$(nix eval --raw "../..#${pname}.version")
latest_tag=$(curl -sf "https://api.github.com/repos/$owner/$repo/releases/latest" | jq -r ".tag_name")
latest=$(echo "$latest_tag" | cut -c2-)

if [[ $current == $latest ]]; then
    echo "$pname is up-to-date: $latest"
    exit 0
fi

sed -i "s/version = \"$current\"/version = \"$latest\"/" default.nix
url=$(nix eval --raw "../..#${pname}.src.urls" --apply builtins.head)
newhash=$(nix-prefetch-url "$url" --unpack)
sed -i "s|sha256 = \".*\"|sha256 = \"$newhash\"|" default.nix

echo "$pname updated: $current -> $latest"
