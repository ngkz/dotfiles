# home-manager configuration for all NixOS hosts
{ lib, config, osConfig, ... }:
let inherit (lib) mkIf;
in {
  # Sync home-manager state version with NixOS state version
  home.stateVersion = osConfig.system.stateVersion;

  systemName = osConfig.system.name;

  programs.btop.settings.disks_filter = "exclude=/var/persist /var/snapshots /var/swap /var/log";
  tmpfs-as-home = {
    enable = osConfig.tmpfs-as-root.enable;
    storage = mkIf osConfig.tmpfs-as-root.enable
      (osConfig.tmpfs-as-root.storage + config.home.homeDirectory);
  };

}
