#!/usr/bin/env bash
set -eu -o pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

nix flake update
for updater in packages/*/update.sh; do
    "$updater"
done
