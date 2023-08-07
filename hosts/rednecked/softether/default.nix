{ config, pkgs, ... }: {
  services.softether = {
    enable = true;
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
    '';
  };

  modules.tmpfs-as-root.persistentDirs = [
    "/var/lib/softether"
  ];

  # see also: sslh.nix
  networking.firewall.allowedUDPPorts = [
    53 # VPN over DNS
    1194 # OpenVPN
  ];
  networking.firewall.allowPing = true; # VPN over ICMP
}
