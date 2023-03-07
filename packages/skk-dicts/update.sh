#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl nixpkgs#nix-prefetch-github nixpkgs#jq -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=skk-dicts
owner=skk-dev
repo1=dict
repo2=skktools
branch=master

current1=$(sed -n 's/.*dict_rev = "\(.*\)";.*/\1/p' default.nix)
commit1=$(curl -sf https://api.github.com/repos/$owner/$repo1/commits/master)
latest1=$(jq -r .sha <<<"$commit1")

current2=$(sed -n 's/.*tools_rev = "\(.*\)";.*/\1/p' default.nix)
commit2=$(curl -sf https://api.github.com/repos/$owner/$repo2/commits/master)
latest2=$(jq -r .sha <<<"$commit2")

if [[ $current1 == "$latest1" ]] && [[ $current2 == "$latest2" ]]; then
    echo "$pname is up-to-date"
    exit 0
fi

date=$(jq -r .commit.committer.date <<<"$commit1")
version=$(date +%Y-%m-%d --date="$date")

newhash1=$(nix-prefetch-github --json "$owner" "$repo1" --rev "$latest1" | jq -r .sha256)
newhash2=$(nix-prefetch-github --json "$owner" "$repo2" --rev "$latest2" | jq -r .sha256)

sed -i "s/version = \".*\"/version = \"$version\"/" default.nix

sed -i "s|dict_rev = \".*\"|dict_rev = \"$latest1\"|" default.nix
sed -i "s|dict_sha256 = \".*\"|dict_sha256 = \"$newhash1\"|" default.nix
sed -i "s|tools_rev = \".*\"|tools_rev = \"$latest2\"|" default.nix
sed -i "s|tools_sha256 = \".*\"|tools_sha256 = \"$newhash2\"|" default.nix

echo "$pname updated:"
echo "$repo1: $current1 -> $latest1 ($version)"
echo "$repo2: $current2 -> $latest2"
