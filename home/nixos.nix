# home-manager configuration for all NixOS hosts
{ osConfig, ... }: {
  # Sync home-manager state version with NixOS state version
  home.stateVersion = osConfig.system.stateVersion;

  systemName = osConfig.system.name;

  programs.btop.settings.disks_filter = "exclude=/var/persist /var/snapshots /var/swap /var/log";
}
