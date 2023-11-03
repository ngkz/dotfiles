{ config, lib, pkgs, ... }:
let
  inherit (lib.ngkz) rot13;

  site = pkgs.stdenvNoCC.mkDerivation {
    name = "f2l.cc";

    src = ./public.tar.xz;

    unpackPhase = ''
      tar -xJf $src
    '';

    installPhase = ''
      cp -a public $out
    '';
  };
in
{
  security.acme.acceptTerms = true;
  security.acme.defaults.email = rot13 "abthpuv.xnmhgbfv+npzr@tznvy.pbz";
  services.nginx = {
    enable = true;
    defaultSSLListenPort = 8443;
    virtualHosts = {
      "f2l.cc" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = { root = "${site}"; };
        extraConfig = ''
          error_page 404 /404.html;
        '';
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 ];

  modules.tmpfs-as-root.persistentDirs = [ "/var/lib/acme" ];
  systemd.services.acme-fixperms.serviceConfig = {
    StateDirectory = lib.mkForce ""; #tmpfs-as-root
    ReadWritePaths = [
      "/var/lib/acme"
      "${config.modules.tmpfs-as-root.storage}/var/lib/acme"
    ];
  };
}
