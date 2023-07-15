{ inputs, config, ... }:
let
  inherit (inputs) agenix;
in
{
  imports = [
    agenix.nixosModules.default
  ];

  age = {
    identityPaths = [ "${config.modules.tmpfs-as-root.storage}/secrets/age.key" ];
  };
}
