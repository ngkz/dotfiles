#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl nixpkgs#nix-prefetch-git -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=blobmoji-fontconfig
current=$(nix eval --raw "../..#${pname}.version")

curl -sL -o .SRCINFO "https://aur.archlinux.org/cgit/aur.git/plain/.SRCINFO?h=blobmoji-fontconfig"
latest="$(sed -n "s/.*pkgver = \(.*\+\).*/\1/p" .SRCINFO)-$(sed -n "s/.*pkgrel = \(.*\+\).*/\1/p" .SRCINFO)"
rm -f .SRCINFO

if [[ $current == $latest ]]; then
    echo "$pname is up-to-date: $latest"
    exit 0
fi

url=$(nix eval --raw "../..#${pname}.src.url")
nix-prefetch-git "$url" >git.json
newrev=$(jq -r .rev <git.json)
newhash=$(jq -r .sha256 <git.json)
rm -f git.json

sed -i "s/version = \"$current\"/version = \"$latest\"/" default.nix
sed -i "s/rev = \".*\"/rev = \"$newrev\"/" default.nix
sed -i "s|sha256 = \".*\"|sha256 = \"$newhash\"|" default.nix

echo "$pname updated: $current -> $latest"
