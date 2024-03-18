#!@bash@/bin/bash
set -eu

export PATH=/empty
for i in @path@; do PATH=$PATH:$i/bin; done

rwstore=/run/nix-maintenance

# Delete configurations older than a week and perform GC
echo "collecting garbages:"
nix-collect-garbage --delete-older-than 7d

# Remove old configurations from the boot menu
/nix/var/nix/profiles/system/bin/switch-to-configuration switch

if [[ "$(findmnt -fno FSTYPE /nix/store)" = btrfs ]]; then
    # nix store is btrfs
    # mount the store in rw mode
    trap "umount $rwstore && rmdir $rwstore" EXIT
    mkdir -p "$rwstore"
    mount --bind /nix/store "$rwstore"
    mount -o remount,rw "$rwstore"

    if ! findmnt -fno OPTIONS /nix/store | grep ssd >/dev/null; then
        # defrag fragmented files in /nix when the store is on HDD
        echo "defragmenting /nix:"
        fragment_threshold=500

        exec 3> >(tee)
        find /nix "$rwstore" -xdev ! -path "/nix/store/*" -type f | \
            xargs -d '\n' filefrag 2>/dev/null | \
            sed 's/^\(.*\): \([0-9]\+\) extent.*/\2 \1/' | \
            awk -F ' ' "\$1 > $fragment_threshold" | \
            sort -n -r | \
            tee /dev/fd/3 | \
            cut -d ' ' -f2 | \
            xargs -d '\n' -r btrfs filesystem defragment -f >/dev/null
        exec 3>&-
    fi
fi

# Replace identical files in the store by hard links
echo "deduplicating the store:"
nix store optimise
