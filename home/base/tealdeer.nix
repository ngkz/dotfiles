{ lib, config, pkgs, ... }:
let
  inherit (lib) hm escapeShellArg;
  tldr_cache = "${config.xdg.cacheHome}/tealdeer/tldrpages";
in
{
  programs.tealdeer = {
    enable = true;
    settings = {
      updates = {
        auto_update = true;
      };
      # move a cache directory to ~/.cache/tealdeer/tldrpages
      # tealdeer deletes the cache directory (default: ~/.cache/tealdeer) and breaks
      # the link to the presistent storage
      directories = {
        cache_dir = tldr_cache;
      };
    };
  };

  tmpfs-as-home.persistentDirs = [
    ".cache/tealdeer"
  ];
}
