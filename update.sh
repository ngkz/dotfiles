#!/usr/bin/env bash
set -eu -o pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

nix flake update
./packages/nodePackages/update.sh
./packages/chromium-extension-ublock0/update.sh
./packages/chromium-extension-mouse-dictionary/update.sh
