{ pkgs, ... }: {
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  users.users.user.extraGroups = [
    "docker"
  ];

  modules.tmpfs-as-root.persistentDirs = [
    "/var/lib/docker"
  ];

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
