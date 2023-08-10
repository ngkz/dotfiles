{ config, lib, pkgs, ... }:
let
  inherit (lib) optionals mkForce;

  adapterMACs = {
    peregrine = "5E-1D-B9-4C-BE-F3";
    noguchi-pc = "5E-76-27-0A-72-C9";
  };
in
{
  services.softether = {
    enable = true;
    package = pkgs.ngkz.softether;
    vpnclient.enable = true;
  };

  age.secrets = {
    "softether-client-secrets".file = ../../../secrets/softether-client-secrets.age;
  };

  systemd.services.vpnclient = {
    wantedBy = mkForce [ ]; # do not autostart
    restartTriggers = [
      config.age.secrets."softether-client-secrets".file
      ./vpn_client.config
    ];
    serviceConfig = {
      # tmpfs-as-root
      ReadWritePaths = optionals config.modules.tmpfs-as-root.enable [ "${config.modules.tmpfs-as-root.storage}${config.services.softether.dataDir}/vpnclient" ];

      # additional hardenings
      ProtectClock = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      SystemCallArchitectures = "native";
      MemoryDenyWriteExecute = true;
      RestrictNamespaces = true;
      RestrictSUIDSGID = true;
      ProtectHostname = true;
      LockPersonality = true;
      ProtectKernelTunables = true;
      NoNewPrivileges = true;
      RemoveIPC = true;
      SystemCallFilter = [ "~@clock" "~@cpu-emulation" "~@debug" "~@module" "~@mount" "~@obsolete" "~@raw-io" "~@reboot" "~@swap" ];
      CapabilityBoundingSet = mkForce [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" "CAP_NET_BROADCAST" "CAP_NET_RAW" "CAP_SYS_NICE" ];
    };
    preStart = ''
      touch ${config.services.softether.dataDir}/vpnclient/vpn_client.config
      chmod 600 ${config.services.softether.dataDir}/vpnclient/vpn_client.config
      source ${config.age.secrets.softether-client-secrets.path}
      ${pkgs.gnused}/bin/sed -e "s|@EncryptedPassword@|$EncryptedPassword|" \
                             -e "s|@Account0ShortcutKey@|$Account0ShortcutKey|" \
                             -e "s|@Account0HashedPassword@|$Account0HashedPassword|" \
                             -e "s|@MAC@|${adapterMACs."${config.system.name}"}|" \
                             ${./vpn_client.config} >${config.services.softether.dataDir}/vpnclient/vpn_client.config

      # tmpfs-as-root: vpnclient can't chmod symlinked log directories
      chmod 700 ${config.modules.tmpfs-as-root.storage}${config.services.softether.dataDir}/vpnclient/client_log
    '';
  };

  modules.tmpfs-as-root.persistentDirs = [
    "${config.services.softether.dataDir}/vpnclient/client_log"
  ];
}
