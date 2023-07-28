#!@bash@/bin/bash
set -euo pipefail

PATH=@path@

export LIBVIRT_DEFAULT_URI=@uri@

vmname=@vmname@
toplevel=@toplevel@
libvirtXML=@libvirtXML@

ensureDisk() {
  pool=$1
  vol=$2
  format=$3
  size=$4

  if [[ "$size" -gt 0 ]]; then
    if ! virsh vol-key --pool "$pool" "$vol" &>/dev/null; then
      virsh vol-create-as --format="$format" "$pool" "$vol" "${size}MiB"
    else
      virsh vol-resize "$vol" "${size}MiB" --pool "$pool"
    fi
  fi
}

@ensureDisks@

uuid=$(virsh domuuid "$vmname" 2>/dev/null || true)
ln -nsf "$toplevel" "/nix/var/nix/gcroots/per-user/$USER/libvirt-vm-$vmname-system"
virsh define <(sed -e "s/__UUID__/$uuid/" \
                   -e "s/__PHYSICAL_CPUS__/$(nproc)/" \
                   "$libvirtXML")
virsh start "$vmname" || true
