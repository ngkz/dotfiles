{ config, ... }:
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
        cache_dir = "${config.xdg.cacheHome}/tealdeer/tldrpages";
      };
    };
  };

  tmpfs-as-home.persistentDirs = [
    ".cache/tealdeer"
  ];
}
