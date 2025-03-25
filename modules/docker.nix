{ pkgs, ... }: {
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  users.users.user.extraGroups = [
    "docker"
  ];

  tmpfs-as-root.persistentDirs = [
    "/var/lib/docker"
  ];

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
