{ inputs, config, pkgs, lib, ... }:
let
  inherit (lib) escapeShellArg makeBinPath concatStringsSep;
  inherit (lib.attrsets) mapAttrsToList mapAttrs' nameValuePair;
  inherit (lib.strings) escapeXML;
  inherit (builtins) toString head;

  cfg = config.modules.libvirt-vm;
  regInfo = pkgs.closureInfo { rootPaths = [ config.system.build.toplevel ]; };
  vmname = config.system.name;
  pool = "default";
  vol = vmname + ".qcow2";

  libvirtXML = pkgs.substituteAll {
    name = "libvirt-${vmname}.xml";
    src = ./template.xml;
    vmname = escapeXML vmname;
    regInfo = escapeXML (toString regInfo);
    vcpu = if cfg.cores != null then cfg.cores else "__PHYSICAL_CPUS__";
    inherit (cfg) memorySize;
    toplevel = escapeXML (toString config.system.build.toplevel);
    kernelParams = escapeXML (toString config.boot.kernelParams);
    disks =
      if cfg.diskSize > 0 then ''
        <disk type='volume' device='disk'>
          <driver name='qemu' type='qcow2'/>
          <source pool='${escapeXML pool}' volume='${escapeXML vol}'/>
          <target dev='vda' bus='virtio'/>
        </disk>
      '' else "";
    sharedMounts =
      concatStringsSep "\n" (
        mapAttrsToList
          (tag: cfg: ''
            <filesystem type='mount' accessmode='passthrough'>
              <driver type='virtiofs'/>
              <!-- XXX workaround for nixpkgs#187078 -->
              <binary path='/run/current-system/sw/bin/virtiofsd' xattr='on'/>
              <source dir='${escapeXML cfg.source}'/>
              <target dir='${escapeXML tag}'/>
            </filesystem>
          '')
          cfg.sharedDirectories
      );
  };

  createVM = pkgs.substituteAll {
    name = "create-libvirt-vm-${vmname}";
    src = ./create-vm.sh;
    isExecutable = true;
    inherit (pkgs) bash;
    path = makeBinPath (with pkgs; [ coreutils libvirt gnused ]);
    vmname = escapeShellArg vmname;
    pool = escapeShellArg pool;
    vol = escapeShellArg vol;
    uri = escapeShellArg cfg.uri;
    inherit libvirtXML;
    inherit (cfg) diskSize;
    toplevel = config.system.build.toplevel;
  };

  destroyVM = pkgs.substituteAll {
    name = "destroy-libvirt-vm-${vmname}";
    src = ./destroy-vm.sh;
    isExecutable = true;
    inherit (pkgs) bash;
    path = makeBinPath (with pkgs; [ coreutils libvirt gnugrep ]);
    vmname = escapeShellArg vmname;
    pool = escapeShellArg pool;
    vol = escapeShellArg vol;
    uri = escapeShellArg cfg.uri;
  };

  sshVM = pkgs.writeShellScript "ssh-libvirt-vm-${vmname}" ''
    PATH=${makeBinPath (with pkgs; [coreutils libvirt openssh gnused])}
    export LIBVIRT_DEFAULT_URI=${escapeShellArg cfg.uri}

    user=${escapeShellArg cfg.sshUser}
    host=$(virsh domifaddr ${escapeShellArg vmname} | sed -En 's/^.*\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\/[0-9]+$/\1/p' | head -n1)
    port=${toString (head config.services.openssh.ports)}
    options='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
    exec ssh -p "$port" $options "$user@$host" "$@"
  '';

  switchVM = pkgs.writeScript "switch-libvirt-vm-${vmname}" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    PATH=${makeBinPath (with pkgs; [coreutils libvirt jq])}
    export LIBVIRT_DEFAULT_URI=${escapeShellArg cfg.uri}

    name=${escapeShellArg vmname}

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

      local pid=$(virsh qemu-agent-command "$name" "{\"execute\": \"guest-exec\", \"arguments\": {\"path\": $(jsonstr "$cmd"), \"arg\": $arg, \"capture-output\": true}}" | jq -r ".return.pid")

      while :; do
        local result=$(virsh qemu-agent-command "$name" "{\"execute\": \"guest-exec-status\", \"arguments\": {\"pid\": $pid}}")
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

    guestrun ${pkgs.runtimeShell} -c "${config.nix.package.out}/bin/nix-store --load-db <${regInfo}/registration"
    guestrun ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system --set ${config.system.build.toplevel}
    guestrun ${config.system.build.toplevel}/bin/switch-to-configuration switch
  '';
in
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
  ];

  boot.initrd.availableKernelModules = [ "overlay" "virtiofs" ];

  # /nix is shared with the host
  fileSystems = {
    "/" = {
      fsType = "ext4";
      device = "/dev/vda";
    };
    "/nix/.ro-store" = {
      fsType = "virtiofs";
      device = "nix-store";
      neededForBoot = true;
      options = [ "ro" ];
    };
    "/nix/store" = {
      fsType = "overlay";
      device = "overlay";
      options = [
        "lowerdir=/nix/.ro-store"
        "upperdir=/nix/.rw-store/store"
        "workdir=/nix/.rw-store/work"
      ];
      depends = [
        "/nix/.ro-store"
        "/nix/.rw-store/store"
        "/nix/.rw-store/work"
      ];
    };
  } // (
    mapAttrs'
      (tag: cfg: nameValuePair cfg.target {
        fsType = "virtiofs";
        device = tag;
      })
      cfg.sharedDirectories
  );

  # use direct boot
  boot.loader.grub.enable = false;

  # don't run ntpd in the guest.  It should get the correct time from KVM.
  services.timesyncd.enable = false;

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # Speed up booting by not waiting for ARP.
  networking.dhcpcd.extraConfig = "noarp";

  networking.usePredictableInterfaceNames = false;

  boot.initrd.extraUtilsCommands =
    ''
      # We need mke2fs in the initrd.
      copy_bin_and_libs ${pkgs.e2fsprogs}/bin/mke2fs
    '';

  boot.initrd.postDeviceCommands =
    ''
      # If the disk image appears to be empty, run mke2fs to
      # initialise.
      FSTYPE=$(blkid -o value -s TYPE ${config.fileSystems."/".device} || true)
      PARTTYPE=$(blkid -o value -s PTTYPE ${config.fileSystems."/".device} || true)
      if test -z "$FSTYPE" -a -z "$PARTTYPE"; then
          mke2fs -t ext4 ${config.fileSystems."/".device}
      fi
    '';

  boot.postBootCommands =
    ''
      # This allows Nix to work in the VM
      # If we had a direct reference to regInfo here, then we would get a cyclic dependency
      if [[ "$(cat /proc/cmdline)" =~ regInfo=([^ ]*) ]]; then
        ${config.nix.package.out}/bin/nix-store --load-db < ''${BASH_REMATCH[1]}
      fi

      touch /etc/NIXOS
      ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system
    '';

  system.build.libvirtVM = pkgs.runCommand "libvirt-vm-${vmname}"
    {
      preferLocalBuild = true;
    } ''
    mkdir -p $out/bin
    ln -s ${config.system.build.toplevel} $out/system
    ln -s ${createVM} $out/bin/create-libvirt-vm-${vmname}
    ln -s ${destroyVM} $out/bin/destroy-libvirt-vm-${vmname}
    ln -s ${sshVM} $out/bin/ssh-libvirt-vm-${vmname}
    ln -s ${switchVM} $out/bin/switch-libvirt-vm-${vmname}
  '';
}
