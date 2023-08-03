#!@bash@/bin/bash
set -euo pipefail

PATH=@path@
export LIBVIRT_DEFAULT_URI=@uri@

name=@vmname@

if virsh list --name | grep "^$name$" >/dev/null; then
  virsh shutdown "$name"
fi

timeout=$(($(date +%s) + 20))
while virsh list --name | grep "^$name$" >/dev/null; do
  if [ "$(date +%s)" -ge "$timeout" ]; then
    virsh destroy "$name"
  else
    # The machine is still running, let's give it some time to shut down
    sleep 0.5
  fi
done

virsh undefine "$name" || true

deleteDisk() {
  pool=$1
  vol=$2

  if virsh vol-key --pool "$pool" "$vol" &>/dev/null; then
    virsh vol-delete --pool "$pool" "$vol"
  fi
}

@deleteDisks@

rm "/nix/var/nix/gcroots/per-user/$USER/libvirt-vm-$name-system"

@extraDestroyVMCommands@
