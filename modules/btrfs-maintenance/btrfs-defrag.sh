#!@bash@/bin/bash

PATH=@path@

FRAGMENT_THRESHOLD=500

exec 3> >(tee)

find "$@" -xdev -type f | \
    xargs -d '\n' filefrag 2>/dev/null | \
    sed 's/^\(.*\): \([0-9]\+\) extent.*/\2 \1/' | \
    awk -F ' ' "\$1 > $FRAGMENT_THRESHOLD" | \
    sort -n -r | \
    tee /dev/fd/3 | \
    cut -d ' ' -f2 | \
    xargs -d '\n' -r btrfs filesystem defragment -f >/dev/null

exec 3>&-
