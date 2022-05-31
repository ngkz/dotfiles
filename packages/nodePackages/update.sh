#!/usr/bin/env bash
set -eu -o pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

nix run nixpkgs#nodePackages.node2nix -- \
    -i node-packages.json \
    --pkg-name nodejs-14_x #XXX workaround for node2nix#236
