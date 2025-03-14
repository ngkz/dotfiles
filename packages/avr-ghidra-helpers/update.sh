#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl nixpkgs#nix-prefetch-github -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=avr-ghidra-helpers
owner=ahroach
repo=avr_ghidra_helpers
branch=master

current=$(nix eval --no-warn-dirty --raw "../..#${pname}.src.rev")
commit=$(curl -sfL https://api.github.com/repos/$owner/$repo/commits/$branch)
latest=$(jq -r .sha <<<"$commit")

if [[ $current == "$latest" ]]; then
    echo "$pname is up-to-date: $latest"
    exit 0
fi

date=$(jq -r .commit.committer.date <<<"$commit")
version=unstable-$(TZ=UTC date +%Y-%m-%d --date="$date")
newhash=$(nix-prefetch-github --json "$owner" "$repo" --rev "$latest" | jq -r .hash)
sed -i "s/version = \".*\"/version = \"$version\"/" default.nix
sed -i "s|rev = \".*\"|rev = \"$latest\"|" default.nix
sed -i "s@\(sha256\|hash\) = \".*\"@hash = \"$newhash\"@" default.nix

echo "$pname updated: $current -> $latest ($version)"
