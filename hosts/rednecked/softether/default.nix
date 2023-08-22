{ config, pkgs, inputs, lib, ... }:
let
  inherit (lib) optionals mkForce;
in
{
  imports = with inputs.self.nixosModules; [
    softether-patched
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
    serviceConfig = {
      # additional hardenings
      RootDirectory = "/var/empty";
      TemporaryFileSystem = "/:ro";
      PrivateMounts = true;
      MountAPIVFS = true;
      PrivateUsers = false; # needs capabilities on the host
      BindReadOnlyPaths = [
        builtins.storeDir
        "-/etc/ld-nix.so.preload"
        "-/etc/resolv.conf"
        "-/etc/nsswitch.conf"
        "-/etc/host.conf"
        "-/etc/hosts"
        "-/etc/services"
        "-/etc/hostname"
        "-/etc/localtime"
        "-/etc/ssl/certs"
        "-/etc/static/ssl/certs"
        "/etc/passwd"
        "/etc/group"
        "/bin/sh"
        config.age.secrets."softether-server-secrets".path
      ];
      BindPaths = [
        "/proc/sys/kernel/threads-max"
        "/proc/sys/net/ipv4/conf/all/arp_filter"
        "${config.services.softether.dataDir}/vpnserver"
      ] ++ (optionals config.modules.tmpfs-as-root.enable [
        "${config.modules.tmpfs-as-root.storage}${config.services.softether.dataDir}/vpnserver"
      ]);
      ProtectSystem = mkForce false; # systemd #18999
      ProtectClock = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectProc = "invisible";
      ProtectHostname = true;
      ProtectKernelTunables = true;
      PrivateDevices = false;
      DeviceAllow = [
        "/dev/net/tun rw"
      ];
      DevicePolicy = "closed";
      SystemCallArchitectures = "native";
      MemoryDenyWriteExecute = true;
      RestrictNamespaces = true;
      RestrictSUIDSGID = true;
      RemoveIPC = true;
      LockPersonality = true;
      NoNewPrivileges = true;
      SystemCallFilter = [ "@system-service" ];
      CapabilityBoundingSet = mkForce [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" "CAP_NET_BROADCAST" "CAP_NET_RAW" "CAP_SYS_NICE" "CAP_SYS_RESOURCE" ];
      RestrictAddressFamilies = [ "AF_NETLINK" "AF_PACKET" "AF_INET" "AF_INET6" ];
    };
    preStart = ''
      touch ${config.services.softether.dataDir}/vpnserver/vpn_server.config
      chmod 600 ${config.services.softether.dataDir}/vpnserver/vpn_server.config
      source ${config.age.secrets.softether-server-secrets.path}
      ${pkgs.gnused}/bin/sed -e "s|@DDnsKey@|$DDnsKey|" \
                             -e "s|@AdminHashedPassword@|$AdminHashedPassword|" \
                             -e "s|@ServerKey@|$ServerKey|" \
                             -e "s|@HubHashedPassword@|$HubHashedPassword|" \
                             -e "s|@HubSecurePassword@|$HubSecurePassword|" \
                             -e "s|@UserAuthNtLmSecureHash@|$UserAuthNtLmSecureHash|" \
                             -e "s|@UserAuthPassword@|$UserAuthPassword|" \
                             ${./vpn_server.config} >${config.services.softether.dataDir}/vpnserver/vpn_server.config
      echo en >${config.services.softether.dataDir}/vpnserver/lang.config

      # tmpfs-as-root: vpnserver can't chmod symlinked log directories
      chmod 700 ${config.modules.tmpfs-as-root.storage}${config.services.softether.dataDir}/vpnserver/{packet_log,security_log,server_log}
    '';
  };

  modules.tmpfs-as-root.persistentDirs = [
    "${config.services.softether.dataDir}/vpnserver/packet_log"
    "${config.services.softether.dataDir}/vpnserver/security_log"
    "${config.services.softether.dataDir}/vpnserver/server_log"
  ];

  # see also: sslh.nix
  networking.firewall.allowedUDPPorts = [
    53 # VPN over DNS
    1194 # OpenVPN
  ];
  networking.firewall.allowPing = true; # VPN over ICMP
}
