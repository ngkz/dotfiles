{ lib, inputs, config, ... }:
let
  inherit (lib) mkIf;
  inherit (inputs) agenix;
in
{
  imports = [
    agenix.nixosModules.default
    ./tmpfs-as-root.nix
  ];

  age = {
    identityPaths = mkIf config.tmpfs-as-root.enable [ "${config.tmpfs-as-root.storage}/secrets/age.key" ];
  };
}
