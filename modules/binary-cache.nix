{ config, ... }:

{
  services.nix-serve = {
    enable = true;
    secretKeyFile = config.age.secrets."cache-priv-key-peregrine.pem".path;
    openFirewall = true;
  };

  age.secrets."cache-priv-key-peregrine.pem" = {
    file = ../secrets/cache-priv-key-peregrine.pem.age;
    owner = "nix-serve";
    mode = "0600";
  };
}
