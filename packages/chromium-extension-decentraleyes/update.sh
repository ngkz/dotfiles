#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=chromium-extension-decentraleyes
current=$(nix eval --raw "../..#${pname}.version")

project_id=$(curl -sf https://git.synz.io/api/v4/projects | jq -r '.[] | select(.path_with_namespace == "Synzvato/decentraleyes") | .id')
curl -sf -o releases.json "https://git.synz.io/api/v4/projects/${project_id}/releases"
latest=$(jq -r 'map(select(contains({description: "-chromium.crx"})))|.[0].tag_name' releases.json | cut -c2-)
url=https://git.synz.io/Synzvato/decentraleyes$(jq -r 'map(select(contains({description: "-chromium.crx"})))|.[0].description' releases.json | sed -n 's/.*(\(.*Decentraleyes.*-chromium.crx\)).*/\1/p')
rm -f releases.json

if [[ $current == $latest ]]; then
    echo "$pname is up-to-date: $latest"
    exit 0
fi

sed -i "s/version = \"$current\"/version = \"$latest\"/" default.nix
sed -i "s|url = \".*\"|url = \"$url\"|" default.nix
newhash=$(nix-prefetch-url "$url")
sed -i "s|sha256 = \".*\"|sha256 = \"$newhash\"|" default.nix

echo "$pname updated: $current -> $latest"
