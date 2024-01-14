{ osConfig, ... }: {
  # Sync home-manager state version with NixOS state version
  home.stateVersion = osConfig.system.stateVersion;
}
