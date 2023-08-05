#!@bash@/bin/bash
set -euo pipefail

PATH=@path@
export LIBVIRT_DEFAULT_URI=@uri@

vmname=@vmname@
bash=@bash@/bin/bash
nix=@nix@
toplevel=@toplevel@
regInfo=@regInfo@
libvirtXML=@libvirtXML@

jsonstr() {
  echo -n "$1" | jq -Rs
}

guestrun() {
  local cmd=$1

  local arg="["
  while shift; do
    arg+=$(jsonstr "$1")
    if [ "$#" -ge 2 ]; then
      arg+=", "
    else
      arg+="]"
      break
    fi
  done

  local pid=$(virsh qemu-agent-command "$vmname" "{\"execute\": \"guest-exec\", \"arguments\": {\"path\": $(jsonstr "$cmd"), \"arg\": $arg, \"capture-output\": true}}" | jq -r ".return.pid")

  while :; do
    local result=$(virsh qemu-agent-command "$vmname" "{\"execute\": \"guest-exec-status\", \"arguments\": {\"pid\": $pid}}")
    if [ "$(jq ".return.exited" <<<"$result")" = true ]; then
      break
    fi
    sleep 0.1
  done

  code=$(jq -r ".return.exitcode" <<<"$result")
  if jq -r '.return["out-data"]' <<<"$result" &>/dev/null; then
    jq -r '.return["out-data"]' <<<"$result" | base64 -d
  fi
  if jq -r '.return["err-data"]' <<<"$result" &>/dev/null; then
    jq -r '.return["err-data"]' <<<"$result" | base64 -d >&2
  fi
  return "$code"
}

guestrun "$bash" -c "$nix/bin/nix-store --load-db <$regInfo/registration"
guestrun "$nix/bin/nix-env" -p /nix/var/nix/profiles/system --set "$toplevel"
guestrun "$toplevel/bin/switch-to-configuration" switch

# update guest config
uuid=$(virsh domuuid "$vmname" 2>/dev/null || true)
ln -nsf "$toplevel" "/nix/var/nix/gcroots/per-user/$USER/libvirt-vm-$vmname-system"
virsh define <(sed -e "s/__UUID__/$uuid/" \
                   -e "s/__PHYSICAL_CPUS__/$(nproc)/" \
                   "$libvirtXML")
