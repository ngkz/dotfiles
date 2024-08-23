#!/usr/bin/env bash
set -eu -o pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

nix flake update --no-warn-dirty
for updater in packages/*/update.sh; do
    "$updater"
done
home/doom-emacs/update.sh
