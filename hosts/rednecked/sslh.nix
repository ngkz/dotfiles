{ config, ... }:
let
  inherit (builtins) head;
in
{
  # sslh multi-protocol multiplexer
  services.sslh = {
    enable = true;
    transparent = true;
    appendConfig = ''
      protocols:
      (
        { name: "ssh"; service: "ssh"; host: "localhost";
          port: "${toString (head config.services.openssh.ports)}";
          keepalive: true; fork: true; tfo_ok: true },
        # SoftEther
        # TODO: sni_hostnames: [ "v.f2l.cc" ]
        { name: "tls"; host: "localhost"; port: "5555"; tfo_ok: true },
        { name: "openvpn"; host: "localhost"; port: "5555"; tfo_ok: true }
      );
    '';
  };

  networking.firewall.allowedTCPPorts = [ 443 ];

  # security.lockKernelModules
  boot.kernelModules = [
    "nft_chain_nat"
    "nf_nat"
    "xt_connmark"
    "xt_owner"
  ];
}
