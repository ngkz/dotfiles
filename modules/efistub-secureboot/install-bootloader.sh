#!@bash@/bin/bash
set -euo pipefail

export PATH=/empty
for i in @path@; do PATH=$PATH:$i/bin; done

default=$1

disk_from_partition() {
    local part disk
    part=$(readlink -f "$1")
    part=${part#/dev/}
    disk=$(readlink "/sys/class/block/$part")
    disk=${disk%/*}
    disk=/dev/${disk##*/}
    echo "$disk"
}

partition_from_mountpoint() {
    local source

    if ! source=$(findmnt -n -o SOURCE "$1"); then
        echo "$1 is not a mount point" >&2
        return 1
    fi

    if [[ $source != /* ]]; then
        echo "$source, the source of $1 is not a block device" >&2
        return 1
    fi

    echo "$source"
    return 0
}

nr_from_generation() {
    sed -En "s|.*/system-([0-9]+)-link$|\1|p" <<<"$1"
}

date_from_generation() {
    stat -c "%y" "$1" | cut -d' ' -f1
}

name_from_generation() {
    echo "@id@ - Cfg $(nr_from_generation "$1") ($(date_from_generation "$1"))"
}

uki_fname_from_generation() {
    echo "system-$(nr_from_generation "$generation").efi"
}

# input output
decrypt() {
    echo >"$2"
    chmod 400 "$2"
    "@age@" --decrypt @ageIdentities@ -o "$2" "$1"
}

# agenix secrets are not yet available when installing bootloader
# so we need to decrypt secrets manually
KEYDIR=$(mktemp -d)
trap 'rm -rf "$KEYDIR"' EXIT

decrypt "@signingKeySecret@" "$KEYDIR/db.key"
decrypt "@signingCertSecret@" "$KEYDIR/db.crt"

ukireldir="/EFI/@id@"
ukidir="@esp@$ukireldir"

mkdir -p "$ukidir"

# generate and sign UKIs
espPart=$(partition_from_mountpoint "@esp@")
espDisk=$(disk_from_partition "$espPart")
espPartNr=$(<"/sys/class/block/${espPart#/dev/}/partition")
declare -A ukisGenerated

for generation in /nix/var/nix/profiles/system-*-link; do
    cmdline="init=$generation/init $(<"$generation/kernel-params")"
    # TODO: non-x86-64 arch
    stub="@systemd@/lib/systemd/boot/efi/linuxx64.efi.stub"
    ukifn=$(uki_fname_from_generation "$generation")
    out="$ukidir/$ukifn"

    if ! sbverify --cert "$KEYDIR/db.crt" "$out" &>/dev/null; then
        objcopy \
            --add-section .osrel="$generation/etc/os-release" --change-section-vma .osrel=0x20000 \
            --add-section .cmdline=<(echo "$cmdline") --change-section-vma .cmdline=0x30000 \
            --add-section .linux="$generation/kernel" --change-section-vma .linux=0x40000 \
            --add-section .initrd="$generation/initrd" --change-section-vma .initrd=0x3000000 \
             "$stub" "$out.tmp"

        sbsign --key "$KEYDIR/db.key" --cert "$KEYDIR/db.crt" --output "$out.tmp" "$out.tmp"
        mv "$out.tmp" "$out"
    fi

    ukisGenerated[$ukifn]=1
done


if [[ "@canTouchEfiVariables@" = "1" ]]; then
    # create boot entries
    declare -A bootEntriesGenerated
    declare -A genNrToBootnum

    for generation in /nix/var/nix/profiles/system-*-link; do
        name=$(name_from_generation "$generation")
        bootnum=$(efibootmgr | (grep -F "$name" | sed -En 's/^Boot([0-9A-F]{4}).*/\1/p' || true))
        genNr=$(sed -En 's|.*/system-([0-9]+)-link$|\1|p' <<<"$generation")

        if [[ -z $bootnum ]]; then
            # create boot entry
            bootnum=$(efibootmgr --create-only --disk "$espDisk" --part "$espPartNr" \
                      --label "$name" \
                      --loader "$ukireldir/$(uki_fname_from_generation "$generation")" \
                      | grep -F "$name" | sed -En 's/^Boot([0-9A-F]{4}).*/\1/p')
        fi

        bootEntriesGenerated[$bootnum]=1
        genNrToBootnum[$genNr]=$bootnum
        if [[ $(readlink -f "$generation") = "$default" ]]; then
            defaultBootnum=$bootnum
            defaultGenNr=$genNr
        fi
    done

    # update boot order
    declare -A nixosEntries

    while read -r bootnum; do
        nixosEntries[$bootnum]=1
    done < <(efibootmgr | sed -En 's/^Boot([0-9A-F]{4})[* ] @id@ - .*/\1/p')

    newBootOrder="$defaultBootnum"

    while read -r genNr; do
        if [[ $genNr -ne $defaultGenNr ]]; then
            newBootOrder+=",${genNrToBootnum[$genNr]}"
        fi
    done < <(ls /nix/var/nix/profiles | sed -En 's/^system-([0-9]+)-link$/\1/p' | sort -nr)

    while read -r bootnum; do
        if [[ ! ${nixosEntries[$bootnum]+1} ]]; then
            newBootOrder+=",$bootnum"
        fi
    done < <(efibootmgr | awk '/^BootOrder: (.*)/ { gsub(",", "\n", $2); print $2 }')
    efibootmgr --bootorder "$newBootOrder" >/dev/null

    # remove obsolete boot entries
    for bootnum in "${!nixosEntries[@]}"; do
        if [[ ! ${bootEntriesGenerated[$bootnum]+1} ]]; then
            efibootmgr --delete-bootnum --bootnum "$bootnum" >/dev/null
        fi
    done
fi

# remove obsolete UKIs from /boot
while read -r ukifn; do
    if [[ ! ${ukisGenerated[$ukifn]+1} ]]; then
        rm "$ukidir/$ukifn"
    fi
done < <(ls "$ukidir")
