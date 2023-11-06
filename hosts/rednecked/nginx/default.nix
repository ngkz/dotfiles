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
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    virtualHosts = {
      "f2l.cc" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = { root = "${site}"; };
        extraConfig = ''
          error_page 404 /404.html;

          # HSTS (ngx_http_headers_module is required) (63072000 seconds)
          add_header Strict-Transport-Security "max-age=63072000" always;
        '';
      };

      "www.f2l.cc" = {
        addSSL = true;
        enableACME = true;
        globalRedirect = "f2l.cc";
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
