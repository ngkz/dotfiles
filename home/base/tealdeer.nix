{ lib, config, pkgs, ... }:
let
  inherit (lib) hm escapeShellArg;
  tldr_cache = "${config.xdg.cacheHome}/tealdeer/tldrpages";
in
{
  # C tldr client is broken
  home.packages = [ pkgs.tealdeer ];

  xdg.configFile."tealdeeer/config.toml".text = ''
    [updates]
    auto_update = true
    auto_update_interval_hours = 720
  '';

  # move a cache directory to ~/.cache/tealdeer/tldrpages
  # tealdeer deletes the cache directory (default: ~/.cache/tealdeer) and breaks
  # the link to the presistent storage
  home.sessionVariables = {
    TEALDEER_CACHE_DIR = tldr_cache;
  };

  home.activation.create-tealdeer-cache = hm.dag.entryAfter [ "linkGeneration" "tmpfs-as-home" ] ''
    $DRY_RUN_CMD mkdir -p ${escapeShellArg tldr_cache}
  '';

  home.tmpfs-as-home.persistentDirs = [
    ".cache/tealdeer"
  ];
}
