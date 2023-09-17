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
          log_level: 1; },
      );
    '';
  };

  networking.firewall.allowedTCPPorts = [ 443 ];
}
