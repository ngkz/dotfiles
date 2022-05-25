#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl -c bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pname=sarasa-term-j-nerd-font
owner=jonz94
repo=Sarasa-Gothic-Nerd-Fonts

current=$(sed -n 's/.*version = "\(.*\)";.*/\1/p' default.nix)
latest_tag=$(curl -s "https://api.github.com/repos/$owner/$repo/releases/latest" | jq -r ".tag_name")
latest=$(echo "$latest_tag" | cut -c2-)

if [[ $current == $latest ]]; then
    echo "$pname is up-to-date: $latest"
    exit 0
fi

echo "update hash by hand :("

echo "$pname updated: $current -> $latest"
