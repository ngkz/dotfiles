{ pkgs, ... }: {
# home-manager configuration for all users

  # automatially trigger X-Restart-Triggers
  systemd.user.startServices = true;
}
