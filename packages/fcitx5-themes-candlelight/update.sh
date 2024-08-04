#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=fcitx5-themes-candlelight
owner=thep0y
repo=$pname

current=$(nix eval --no-warn-dirty --raw "../..#${pname}.rev")
commit=$(curl -sfL https://api.github.com/repos/$owner/$repo/commits/main)
latest=$(jq -r .sha <<<"$commit")

if [[ $current == "$latest" ]]; then
    echo "$pname is up-to-date: $latest"
    exit 0
fi

sed -i "s|rev = \".*\"|rev = \"$latest\"|" default.nix
newhash=$(nix build --no-link "../..#${pname}" 2>&1 | sed -n "s/.*got:\s*\(.*\)/\1/p" || true)
if [[ -n $newhash ]]; then
    sed -i "s|sha256 = \".*\"|sha256 = \"$newhash\"|" default.nix
fi

echo "$pname updated: $current -> $latest"
