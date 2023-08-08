{ config, pkgs, inputs, ... }: {
  disabledModules = [
    "${inputs.nixpkgs}/nixos/modules/services/networking/softether.nix"
  ];

  imports = [
    ./module.nix
  ];

  services.softether = {
    enable = true;
    package = pkgs.ngkz.softether;
    vpnserver.enable = true;
  };

  age.secrets = {
    "softether-server-secrets".file = ../../../secrets/softether-server-secrets.age;
  };

  systemd.services.vpnserver = {
    restartTriggers = [
      config.age.secrets."softether-server-secrets".file
      ./vpn_server.config
    ];
    preStart = ''
      touch /var/lib/softether/vpnserver/vpn_server.config
      chmod 600 /var/lib/softether/vpnserver/vpn_server.config
      source ${config.age.secrets.softether-server-secrets.path}
      ${pkgs.gnused}/bin/sed -e "s|@DDnsKey@|$DDnsKey|" \
                             -e "s|@AdminHashedPassword@|$AdminHashedPassword|" \
                             -e "s|@ServerKey@|$ServerKey|" \
                             -e "s|@HubHashedPassword@|$HubHashedPassword|" \
                             -e "s|@HubSecurePassword@|$HubSecurePassword|" \
                             -e "s|@UserAuthNtLmSecureHash@|$UserAuthNtLmSecureHash|" \
                             -e "s|@UserAuthPassword@|$UserAuthPassword|" \
                             ${./vpn_server.config} >/var/lib/softether/vpnserver/vpn_server.config
      echo en >/var/lib/softether/vpnserver/lang.config

      # tmpfs-as-root: vpnserver can't chmod symlinked log directories
      chmod 700 ${config.modules.tmpfs-as-root.storage}/var/lib/softether/vpnserver/{packet_log,security_log,server_log}
    '';
  };

  modules.tmpfs-as-root.persistentDirs = [
    "/var/lib/softether/vpnserver/packet_log"
    "/var/lib/softether/vpnserver/security_log"
    "/var/lib/softether/vpnserver/server_log"
  ];

  # see also: sslh.nix
  networking.firewall.allowedUDPPorts = [
    53 # VPN over DNS
    1194 # OpenVPN
  ];
  networking.firewall.allowPing = true; # VPN over ICMP
}
