# home-manager configuration for all NixOS hosts
{ lib, config, osConfig, ... }:
let inherit (lib) mkIf;
in {
  imports = [
    ./base.nix
    ./btop.nix
    ./tmpfs-as-home.nix
  ];

  # Sync home-manager state version with NixOS state version
  home.stateVersion = osConfig.system.stateVersion;

  systemName = osConfig.system.name;

  tmpfs-as-home.storage = mkIf osConfig.tmpfs-as-root.enable
    (osConfig.tmpfs-as-root.storage + config.home.homeDirectory);

  btop.tmpfs-as-root-filter = osConfig.tmpfs-as-root.enable;
}
