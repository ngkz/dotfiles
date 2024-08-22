# multiast dns server/resolver
{ ... }:

{
  services.avahi = {
    enable = true;
    nssmdns4 = true; # *.local resolution
    publish = {
      enable = true;
      addresses = true; # make this host accessible with <hostname>.local
      workstation = true;
    };
  };
}
