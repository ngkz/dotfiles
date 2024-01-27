#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl nixpkgs#nix-prefetch-github -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=flygrep-vim
owner=wsdjeg
repo=FlyGrep.vim
branch=master

current=$(nix eval --no-warn-dirty --raw "../..#${pname}.src.rev")
commit=$(curl -sf https://api.github.com/repos/$owner/$repo/commits/$branch)
latest=$(jq -r .sha <<<"$commit")

if [[ $latest == "71737401648c85af21e1af28819cad55f6ab2b62" ]]; then
    echo "$pname: known bad commit"
    exit 0
fi

if [[ $current == "$latest" ]]; then
    echo "$pname is up-to-date: $latest"
    exit 0
fi

newhash=$(nix-prefetch-github --json "$owner" "$repo" --rev "$latest" | jq -r .hash)
sed -i "s|rev = \".*\"|rev = \"$latest\"|" default.nix
sed -i "s@\(sha256\|hash\) = \".*\"@hash = \"$newhash\"@" default.nix

echo "$pname updated: $current -> $latest"
