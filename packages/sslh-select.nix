{ sslh, ... }:
sslh.overrideAttrs (finalAttrs: previousAttrs: {
  pname = "sslh-select";
  postInstall = ''
    install sslh-fork $out/sbin/sslh-fork
    install sslh-select $out/sbin/sslh-select
    ln -sf $out/sbin/sslh-select $out/sbin/sslh
  '';
})
