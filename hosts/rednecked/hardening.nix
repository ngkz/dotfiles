{ inputs, ... }:
let
  inherit (inputs) nixpkgs;
in
{
  imports = [
    "${nixpkgs}/nixos/modules/profiles/hardened.nix"
  ];

  # this is fucking annoying
  security.lockKernelModules = false;

  # additional hardening
  security.allowSimultaneousMultithreading = true;
  services.dbus.apparmor = "enabled";
}
