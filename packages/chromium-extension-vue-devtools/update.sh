#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl nixpkgs#prefetch-yarn-deps nixpkgs#nix-prefetch-github nixpkgs#jq -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=chromium-extension-vue-devtools
owner=vuejs
repo=devtools

current=$(nix eval --raw "../..#${pname}.version")
latest_tag=$(curl -s "https://api.github.com/repos/$owner/$repo/releases/latest" | jq -r ".tag_name")
latest=$(echo "$latest_tag" | cut -c2-)

if [[ $current == $latest ]]; then
    echo "$pname is up-to-date: $latest"
    exit 0
fi

sed -i "s/version = \"$current\"/version = \"$latest\"/" default.nix
newhash=$(nix-prefetch-github --json "$owner" "$repo" --rev "$latest_tag" | jq -r .sha256)
sed -i "s|src_sha256 = \".*\"|src_sha256 = \"$newhash\"|" default.nix

trap 'rm -f source' EXIT
# download source
nix build -o source "../../#${pname}.src"
yarn_hash=$(prefetch-yarn-deps source/yarn.lock)
sed -i "s|yarn_sha256 = \".*\"|yarn_sha256 = \"$yarn_hash\"|" default.nix

echo "$pname updated: $current -> $latest"
