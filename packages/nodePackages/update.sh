#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#nodePackages.node2nix nixpkgs#nixpkgs-fmt -c bash
set -eu -o pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

node2nix \
    -i node-packages.json \
    --pkg-name nodejs-14_x #XXX workaround for node2nix#236

nixpkgs-fmt .
