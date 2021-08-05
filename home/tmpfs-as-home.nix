{ lib, config, nixosConfig ? {}, ... }:
let
  inherit (builtins) listToAttrs;
  inherit (lib) nameValuePair hm concatStringsSep escapeShellArg mkOption
                types unique;
in {
  options.home.tmpfs-as-home = {
    storage = mkOption {
      type = types.str;
      default = (
        if nixosConfig ? modules.tmpfs-as-root then
          nixosConfig.modules.tmpfs-as-root.storage + config.home.homeDirectory
        else
          null
      );
      description = "Path of persistent storage";
    };

    persistentDirs = mkOption {
      type = with types; listOf string;
      default = [];
      description = "Directories which should be stored in the persistent storage.";
    };

    persistentFiles = mkOption {
      type = with types; listOf string;
      default = [];
      description = "Files which should be stored in the persistent storage.";
    };
  };

  config = let
    cfg = config.home.tmpfs-as-home;
    files = cfg.persistentFiles;
    dirs = cfg.persistentDirs;
    storage = cfg.storage;
    storageDirs = map (path: "${storage}/${path}") (unique ((map dirOf files) ++ dirs));
  in {
    home.file = listToAttrs (
      map (
        path: nameValuePair path {
          source = config.lib.file.mkOutOfStoreSymlink "${storage}/${path}";
        }
      ) (files ++ dirs)
    );

    home.activation.tmpfs-as-home = hm.dag.entryAfter ["writeBoundary"] (
      concatStringsSep "\n" (
        map (path: "$DRY_RUN_CMD mkdir -p ${escapeShellArg path}") storageDirs
      )
    );
  };
}
