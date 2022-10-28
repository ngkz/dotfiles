#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl nixpkgs#nix-prefetch-github nixpkgs#jq -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=emacs-pgtk-nativecomp
owner=flatwhatson
repo=emacs
branch=pgtk-nativecomp-dev

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

nix build -o source "../../#${pname}.src"
version=$(sed -n "s/AC_INIT(GNU Emacs, \(\S\+\), .*/\1/p" source/configure.ac)
rm source
sed -i "s/version = \".*\"/version = \"$version\"/" default.nix

echo "$pname updated: $current -> $latest ($version)"
