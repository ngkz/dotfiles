#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl nixpkgs#nix-prefetch-github nixpkgs#jq -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

owner=doomemacs
repo=doomemacs

current=$(sed -n "s/\s*rev = \"\(.*\)\".*/\1/p" default.nix)
commit=$(curl -sfL https://api.github.com/repos/$owner/$repo/commits/master)
latest=$(jq -r .sha <<<"$commit")

if [[ $current == "$latest" ]]; then
    echo "$repo is up-to-date: $latest"
    exit 0
fi

newhash=$(nix-prefetch-github --json "$owner" "$repo" --rev "$latest" | jq -r .hash)
sed -i "s|rev = \".*\"|rev = \"$latest\"|" default.nix
sed -i "s@\(sha256\|hash\) = \".*\"@hash = \"$newhash\"@" default.nix

echo "$repo updated: $current -> $latest"
