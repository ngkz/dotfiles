{ config, ... }:

{
  services.nix-serve = {
    enable = true;
    secretKeyFile = config.age.secrets."cache-priv-key-peregrine.pem".path;
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ config.services.nix-serve.port ];

  users.groups.nix-serve = { };
  users.users.nix-serve = {
    description = "Nix binary cache";
    group = "nix-serve";
    isSystemUser = true;
  };

  age.secrets."cache-priv-key-peregrine.pem" = {
    file = ../secrets/cache-priv-key-peregrine.pem.age;
    owner = "nix-serve";
    group = "nix-serve";
    mode = "0600";
  };
}
