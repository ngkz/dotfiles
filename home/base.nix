# home-manager configuration for all hosts
{ pkgs, ... }: {
  imports = [
    ./tmpfs-as-home.nix
    ./cli-base.nix
  ];

  # automatially trigger X-Restart-Triggers
  systemd.user.startServices = true;
}
