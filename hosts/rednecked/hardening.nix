{ inputs, ... }:
let
  inherit (inputs) nixpkgs;
in
{
  imports = [
    "${nixpkgs}/nixos/modules/profiles/hardened.nix"
  ];

  # security.lockKernelModules = false;

  # additional hardening
  security.allowSimultaneousMultithreading = true;
  services.dbus.apparmor = "enabled";
}
