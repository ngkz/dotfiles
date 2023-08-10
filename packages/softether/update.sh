#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl nixpkgs#gnugrep nixpkgs#gnused nixpkgs#jq nixpkgs#nix-prefetch-github -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=softether
owner=SoftEtherVPN
repo=SoftEtherVPN_Stable

current_ver=$(nix eval --no-warn-dirty --raw "../..#${pname}.version")
latest_tag=$(curl -s "https://api.github.com/repos/$owner/$repo/tags" | jq -r ".[].name" | grep -- "-rtm" | head -n1)
latest_ver=$(sed -E 's/v(.+)-.+-rtm/\1/' <<<"$latest_tag")
latest_build=$(sed -E 's/v.+-(.+)-rtm/\1/' <<<"$latest_tag")

if [[ $current_ver == $latest_ver ]]; then
  echo "$pname is up-to-date: $latest_ver"
  exit 0
fi

newhash=$(nix-prefetch-github --json "$owner" "$repo" --rev "$latest_tag" | jq -r .sha256)

sed -i "s#version = \".*\"#version = \"$latest_ver\"#" default.nix
sed -i "s#build = \".*\"#build = \"$latest_build\"#" default.nix
sed -i "s#sha256 = \".*\"#sha256 = \"$newhash\"#" default.nix

echo "$pname updated: $current_ver -> $latest_ver"
