#!@bash@/bin/bash

set -uo pipefail

PATH=@path@:/run/wrappers/bin

SCRIPT=$(readlink -f "$0")

TMPDIR=/run/backup
DEST_UUID="DE3CFF543CFF25E5"
DEST_MOUNTPOINT=
BORG_REPO_DIR="borg"
ARCHIVE_PREFIX="$(hostname)_"
PRUNE_CONFIG="--keep-within=7d --keep-daily=7 --keep-weekly=2 --keep-monthly=-1"
MOUNT_MOUNTPOINT=$TMPDIR/backup
VERIFY=0
AFTER=nop
CHECK=0
COMPRESSION=zstd,5
BACKUP_PATH=/var/persist
SNAPSHOT_VOLS=(
    /var/persist
    /var/persist/home
)
SNAPSHOT_MOUNTPOINT=$TMPDIR/snapshot
SNAPSHOT_ROOT=/var/snapshots
SNAPSHOT_PREFIX=backup-
EXCLUDES=(
    boot
    var/cache
    var/tmp
    "home/*/.cache"
    root/.cache
    "home/*/.local/var/pmbootstrap"
    "home/*/.local/state/syncthing/index-*.db"
    "var/lib/systemd/random-seed"
    "var/lib/systemd/coredump"
    "home/*/.local/share/TauonMusicBox/scaled-icons"
    "home/*/.android/adb.*"
    "home/*/.FreeCAD/webdatapersistent"
    "home/*/.librewolf/default/storage/default/*/cache"
    "home/*/.electrum/daemon_rpc_socket"
    "home/*/.config/doom-local/autosave"
    "home/*/.config/doom-local/comp"
    "home/*/.config/doom-local/cache/eln"
    "home/*/.config/doom-local/pcache"
    "home/*/.config/doom-local/profiles.@.el"
    "home/*/.config/doom-local/projectile.cache"
    "home/*/.config/doom-local/env"
    "home/*/.config/doom-local/etc/@"
    "home/*/.config/doom-local/etc/scratch"
    "home/*/.config/doom-local/etc/transient"
    "home/*/.config/doom-local/hash"
    "home/*/.config/doom-local/state/logs"
    "home/*/.config/doom-local/straight"
    "home/*/.config/doom-load"
    "home/*/docs/all"
    "home/*/misc/all"
    "home/*/misc/allpc"
    "home/*/projects/allpc"
    var/lib/docker
)
DIFF_CONFIG="--sort --content-only"
LOGGER_PIPE=$TMPDIR/logger

log() {
    echo "[$(date "+%Y/%m/%d %H:%M:%S")] $1"
}

disk_from_partition() {
    local part disk
    part=$(readlink -f "$1")
    part=${part#/dev/}
    disk=$(readlink -)
    disk=${disk%/*}
    disk=/dev/${disk##*/}
    echo "$disk"
}

umount_retry() {
    local progress=0
    local err

    while ! err=$(LC_MESSAGES=C umount "$1" 2>&1); do
        if ! grep ": target is busy\.$" <<<"$err" >/dev/null; then
            [[ "$progress" -eq 1 ]] && echo
            echo "$err" >&2
            return 1
        fi
        if [[ "$progress" -eq 0 ]]; then
            echo -n "[$(date "+%Y/%m/%d %H:%M:%S")] unmounting $1"
            progress=1
        else
            echo -n "."
        fi
        sleep 1
    done

    [[ "$progress" -eq 1 ]] && echo
    return 0
}

find_dest() {
    while :; do
        if DEST_MOUNTPOINT=$(findmnt -noTARGET /dev/disk/by-uuid/$DEST_UUID); then
            break
        fi
        log "mount the backup disk."
        sleep 1
    done

    export BORG_REPO=$DEST_MOUNTPOINT/$BORG_REPO_DIR
    return 0
}

log_output() {
    mkfifo "$LOGGER_PIPE" || return 1
    logger -t backup <"$LOGGER_PIPE" &
    LOGGER_PID=$!
    exec 3>&1 4>&2 > >(tee "$LOGGER_PIPE") 2> >(tee "$LOGGER_PIPE" >&2)
}

log_output_stop() {
    exec 1>&3 2>&4 3>&- 4>&-
    wait "$LOGGER_PID" # wait until tees flush the buffer and exit
    rm -f "$LOGGER_PIPE"
}

take_snapshots() {
    for path in "${SNAPSHOT_VOLS[@]}"; do
        if ! btrfs subvolume snapshot -r "$path" "$SNAPSHOT_ROOT/${SNAPSHOT_PREFIX}${path//\//-}" >/dev/null; then
            btrfs subvolume delete "$SNAPSHOT_ROOT/$SNAPSHOT_PREFIX"* >/dev/null
            return 1
        fi
    done

    if ! mkdir "$SNAPSHOT_MOUNTPOINT"; then
        btrfs subvolume delete "$SNAPSHOT_ROOT/$SNAPSHOT_PREFIX"* >/dev/null
        return 1
    fi

    if ! mount --bind "$SNAPSHOT_MOUNTPOINT" "$SNAPSHOT_MOUNTPOINT"; then
        rm -rf "$SNAPSHOT_MOUNTPOINT"
        btrfs subvolume delete "$SNAPSHOT_ROOT/$SNAPSHOT_PREFIX"* >/dev/null
        return 1
    fi

    for path in "${SNAPSHOT_VOLS[@]}"; do
        if ! mkdir -p "$SNAPSHOT_MOUNTPOINT/$path"; then
            umount -R "$SNAPSHOT_MOUNTPOINT"
            rm -rf "$SNAPSHOT_MOUNTPOINT"
            btrfs subvolume delete "$SNAPSHOT_ROOT/$SNAPSHOT_PREFIX"* >/dev/null
            return 1
        fi
        if ! mount --bind "$SNAPSHOT_ROOT/${SNAPSHOT_PREFIX}${path//\//-}" "$SNAPSHOT_MOUNTPOINT/$path";  then
            umount -R "$SNAPSHOT_MOUNTPOINT"
            rm -rf "$SNAPSHOT_MOUNTPOINT"
            btrfs subvolume delete "$SNAPSHOT_ROOT/$SNAPSHOT_PREFIX"* >/dev/null
            return 1
        fi
    done
}

rm_snapshots() {
    umount -R "$SNAPSHOT_MOUNTPOINT"
    rm -rf "$SNAPSHOT_MOUNTPOINT"
    btrfs subvolume delete "$SNAPSHOT_ROOT/$SNAPSHOT_PREFIX"* >/dev/null
}

backup() {
    log_output

    if ! find_dest; then
        log_output_stop
        return 1
    fi

    if ! take_snapshots; then
        log_output_stop
        return 1
    fi

    local excludes_borg=$TMPDIR/exclude-borg
    local excludes_rsync=$TMPDIR/exclude-rsync

    for path in "${EXCLUDES[@]}"; do
        echo "sh:$path" >>"$excludes_borg"
        echo "/$path" >>"$excludes_rsync"
    done
    # cache directories
    (cd "$SNAPSHOT_MOUNTPOINT$BACKUP_PATH" && find -name CACHEDIR.TAG -type f | sed -E 's|^\./(.*)/[^/]*$|\1|') | while read -r path; do
        # TODO escape meta characters
        echo "pf:$path" >>"$excludes_borg"
        echo "/$path" >>"$excludes_rsync"
    done

    local archive_prev=$(borg list --glob-archives "${ARCHIVE_PREFIX}*" --format "{archive}{NL}" --sort-by timestamp --last 1 ::)

    log "starting backup"
    local archive=$ARCHIVE_PREFIX$(date +%Y-%m-%d_%H-%M-%S)
    if ! (cd "$SNAPSHOT_MOUNTPOINT$BACKUP_PATH" && borg create --stats --compression "$COMPRESSION" --exclude-from "$excludes_borg" "::$archive" .); then
        rm_snapshots
        log_output_stop
        return 1
    fi

    if [[ $VERIFY -ne 0 ]]; then
        if ! verify "$archive" "$SNAPSHOT_MOUNTPOINT$BACKUP_PATH" "$excludes_rsync"; then
            rm_snapshots
            log_output_stop
            return 1
        fi
    fi

    rm -f "$excludes_rsync" "$excludes_borg"
    if ! rm_snapshots; then
        log_output_stop
        return 1
    fi

    if [[ -n "$archive_prev" ]]; then
        log "$archive_prev -> $archive diff:"
        if ! borg diff "::$archive_prev" "$archive" $DIFF_CONFIG; then
            log_output_stop
            return 1
        fi
    fi

    log "deleting old backups"
    if ! borg prune --list --glob-archives "${ARCHIVE_PREFIX}*" $PRUNE_CONFIG ::; then
        log_output_stop
        return 1
    fi

    if ! borg compact ::; then
        log_output_stop
        return 1
    fi

    if [[ $CHECK -ne 0 ]]; then
        log "checking repository"
        if ! borg check ::; then
            log_output_stop
            return 1
        fi
    fi

    if [[ $(LC_MESSAGES=C df -h "$DEST_MOUNTPOINT" | awk '!/Filesystem/ { sub(/%/, "", $5); print $5 }') -ge 95 ]]; then
        log "warning: the backup disk is almost full"
        df -h "$DEST_MOUNTPOINT"
    fi

    local rc=0
    log_output_stop || rc=1
    return "$rc"
}

# verify ARCHIVE TARGET EXCLUDES
verify() {
    local archive=$1
    local target=$2
    local excludes=$3

    log "verifying $archive"

    mkdir "$MOUNT_MOUNTPOINT" || return 1
    if ! borg mount --numeric-ids "::$archive" "$MOUNT_MOUNTPOINT"; then
        rmdir "$MOUNT_MOUNTPOINT"
        return 1
    fi

    local rc=0
    # borg mount does not support ACL
    if ! rsync --numeric-ids -aHXvc --delete --dry-run --exclude-from="$excludes" "$target/" "$MOUNT_MOUNTPOINT"; then
        log "couldn't verify $archive"
        rc=1
    fi

    umount_retry "$MOUNT_MOUNTPOINT" || rc=1
    rmdir "$MOUNT_MOUNTPOINT" || rc=1
    return "$rc"
}

mount_repository() {
    log "mounting the repository at $MOUNT_MOUNTPOINT"

    find_dest || return 1
    if ! mkdir "$MOUNT_MOUNTPOINT"; then
        return 1
    fi

    local rc=0
    if ! borg mount -o allow_other -f :: "$MOUNT_MOUNTPOINT"; then
        log "can't mount $BORG_REPO to $MOUNT_MOUNTPOINT"
        rc=1
    fi

    rmdir "$MOUNT_MOUNTPOINT" || rc=1
    return "$rc"
}

shell() {
    find_dest || return 1

    export DEST_MOUNTPOINT
    export ARCHIVE_PREFIX
    export PRUNE_CONFIG

    echo "DEST_MOUNTPOINT=$DEST_MOUNTPOINT"
    echo "BORG_REPO=$BORG_REPO"
    echo "ARCHIVE_PREFIX=$ARCHIVE_PREFIX"
    echo "PRUNE_CONFIG=$PRUNE_CONFIG"

    (cd "$DEST_MOUNTPOINT" && @bashInteractive@/bin/bash)
}

usage() {
    local name=$(basename "$0")
    echo "Usage:" >&2
    echo "$name backup [--verify] [--check] [suspend|hibernate|poweroff]" >&2
    echo "$name mount" >&2
    echo "$name shell" >&2
}

if [[ $# -lt 1 ]]; then
     usage
     exit 1
fi

ACTION=$1
case "$ACTION" in
backup)
    for arg in "${@:2}"; do
        case "$arg" in
        --verify) VERIFY=1 ;;
        --check) CHECK=1 ;;
        suspend | hibernate | poweroff)
            if [[ "$AFTER" != nop ]]; then
                usage
                exit 1
            fi
            AFTER=$arg
            ;;
        *)
            usage
            exit 1
            ;;
        esac
    done
    ;;
mount|shell)
    if [[ $# -gt 1 ]]; then
        usage
        exit 1
    fi
    ;;
*)
    usage
    exit 1
    ;;
esac

mkdir "$TMPDIR" || exit 1

rc=0

case "$ACTION" in
backup)
    backup || rc=1
    ;;
mount)
    mount_repository || rc=1
    ;;
shell)
    shell || rc=1
    ;;
esac

rm -rf --one-file-system "$TMPDIR" || rc=1

case "$AFTER" in
poweroff) poweroff || rc=1 ;;
hibernate) systemctl hibernate || rc=1 ;;
suspend) systemctl suspend || rc=1 ;;
esac

exit "$rc"
