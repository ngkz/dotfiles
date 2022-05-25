#!/usr/bin/env bash
set -eu -o pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

nix flake update
./packages/nodePackages/update.sh
