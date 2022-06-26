{ config, lib, ... }: {
  # NetworkManager
  networking.useDHCP = false;
  networking.networkmanager = {
    enable = true;
    wifi = {
      powersave = true;
      scanRandMacAddress = true;
      backend = "iwd";
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

  users.users.user.extraGroups = [
    "networkmanager"
  ];

  modules.tmpfs-as-root.persistentDirs = [
    "/var/lib/NetworkManager"
  ];

  systemd.services.NetworkManager.serviceConfig = {
    StateDirectory = lib.mkForce "";
    ReadWritePaths = [
      "/var/lib/NetworkManager"
      "${config.modules.tmpfs-as-root.storage}/var/lib/NetworkManager"
    ];
  };
}
