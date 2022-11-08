#!/usr/bin/env bash
set -eu -o pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

nix flake update --no-warn-dirty
for updater in packages/*/update.sh; do
    "$updater"
done
./home/workstation/luakit/update.sh
./home/workstation/doom-emacs/update.sh
