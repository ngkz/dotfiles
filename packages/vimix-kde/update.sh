#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl nixpkgs#nix-prefetch-github -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=vimix-kde
owner=vinceliuice
repo=vimix-kde
branch=master

current=$(nix eval --no-warn-dirty --raw "../..#${pname}.src.rev")
commit=$(curl -sf https://api.github.com/repos/$owner/$repo/commits/$branch)
latest=$(jq -r .sha <<<"$commit")

if [[ $current == "$latest" ]]; then
    echo "$pname is up-to-date: $latest"
    exit 0
fi

newhash=$(nix-prefetch-github --json "$owner" "$repo" --rev "$latest" | jq -r .sha256)
sed -i "s|rev = \".*\"|rev = \"$latest\"|" default.nix
sed -i "s|sha256 = \".*\"|sha256 = \"$newhash\"|" default.nix

echo "$pname updated: $current -> $latest"
