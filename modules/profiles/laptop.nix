{ inputs, lib, config, ... }:
let
  inherit (inputs) self nixos-hardware;
  inherit (lib) mkForce;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-pc-laptop
  ];

  systemd.services.tlp-sleep.serviceConfig = {
    StateDirectory = mkForce "";
    ReadWritePaths = [
      "/var/lib/tlp"
      "${config.tmpfs-as-root.storage}/var/lib/tlp"
    ];
  };

  services.tlp.enable = true;
  tmpfs-as-root.persistentDirs = [
    # tlp
    "/var/lib/tlp"
  ];
}
