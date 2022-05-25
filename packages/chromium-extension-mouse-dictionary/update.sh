#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl nixpkgs#nodePackages.node2nix nixpkgs#nix-prefetch-github nixpkgs#jq -c bash -x
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=chromium-extension-mouse-dictionary
owner=wtetsu
repo=mouse-dictionary

current=$(nix eval --raw "../..#${pname}.version")
latest_tag=$(curl -s "https://api.github.com/repos/$owner/$repo/releases/latest" | jq -r ".tag_name")
latest=$(echo "$latest_tag" | cut -c2-)

if [[ $current == $latest ]]; then
    echo "$pname is up-to-date: $latest"
    exit 0
fi

sed -i "s/version = \"$current\"/version = \"$latest\"/" default.nix
newhash=$(nix-prefetch-github --json "$owner" "$repo" --rev "$latest_tag" | jq -r .sha256)
sed -i "s|sha256 = \".*\"|sha256 = \"$newhash\"|" default.nix

trap 'rm -f source' EXIT
# download source
nix build -o source ../../#chromium-extension-mouse-dictionary.src
cp source/package.json source/package-lock.json .

node2nix \
    --input package.json \
    --lock package-lock.json \
    --composition node.nix \
    --development \
    --no-copy-node-env \
    --node-env ../nodePackages/node-env.nix \
    --pkg-name nodejs

echo "$pname updated: $current -> $latest"
