# NetworkManager
{ config, pkgs, lib, ... }: {
  options.network-manager = {
    connections = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
    };
  };

  config = {
    networking.useDHCP = false;
    networking.networkmanager = {
      enable = true;
      wifi = {
        powersave = true;
        scanRandMacAddress = true;
        # Generate a random MAC for each WiFi and associate the two permanently.
        macAddress = "stable";
      };
      # Randomize MAC for every ethernet connetion
      ethernet.macAddress = "random";
      connectionConfig = {
        # IPv6 Privacy Extensions
        "ipv6.ip6-privacy" = 2;

        # unique DUID per connection
        "ipv6.dhcp-duid" = "stable-uuid";
      };
    };

    environment.etc = {
      "NetworkManager/dispatcher.d/10-dhcp-ntp".source = pkgs.substituteAll {
        src = ./dhcp-ntp.sh;
        isExecutable = true;
        inherit (pkgs) bash;
        path = with pkgs; [ coreutils util-linux systemd ];
      };
    } // (builtins.foldl'
      (acc: file: acc // {
        "NetworkManager/system-connections/${file}.nmconnection".source = config.age.secrets."${file}.nmconnection".path;
      })
      { }
      config.network-manager.connections);

    age.secrets = builtins.foldl'
      (acc: file: acc // {
        "${file}.nmconnection".file = ../../secrets/${file}.nmconnection.age;
      })
      { }
      config.network-manager.connections;

    users.users.user.extraGroups = [
      "networkmanager"
    ];

    tmpfs-as-root.persistentDirs = [
      "/var/lib/NetworkManager"
    ];

    systemd.services.NetworkManager.serviceConfig = {
      StateDirectory = lib.mkForce "";
      ReadWritePaths = [
        "/var/lib/NetworkManager"
        "${config.tmpfs-as-root.storage}/var/lib/NetworkManager"
      ];
    };
  };
}
