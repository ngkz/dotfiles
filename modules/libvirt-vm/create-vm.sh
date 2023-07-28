#!@bash@/bin/bash
set -euo pipefail

PATH=@path@

export LIBVIRT_DEFAULT_URI=@uri@

vmname=@vmname@
pool=@pool@
vol=@vol@
diskSize=@diskSize@
toplevel=@toplevel@
libvirtXML=@libvirtXML@

if [[ $diskSize -gt 0 ]]; then
  if ! virsh vol-key --pool "$pool" "$vol" &>/dev/null; then
    virsh vol-create-as --format=qcow2 "$pool" "$vol" "${diskSize}GiB"
  elif ! [[ $(virsh vol-info "$vol" --pool "$pool" | sed -En 's/Capacity:\s*(.*)/\1/p') != "${diskSize} GiB" ]]; then
    virsh vol-resize "$vol" "${diskSize}GiB" --pool "$pool"
  fi
fi

uuid=$(virsh domuuid "$vmname" 2>/dev/null || true)
ln -nsf "$toplevel" "/nix/var/nix/gcroots/per-user/$USER/libvirt-vm-$vmname-system"
virsh define <(sed -e "s/__UUID__/$uuid/" \
                   -e "s/__PHYSICAL_CPUS__/$(nproc)/" \
                   "$libvirtXML")
virsh start "$vmname" || true
