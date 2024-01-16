# tmpfs as root: home-manager edition
{ lib, config, ... }:
let
  inherit (builtins) listToAttrs;
  inherit (lib) nameValuePair hm concatStringsSep escapeShellArg mkOption
    types unique mkEnableOption mkIf;
in
{
  options.tmpfs-as-home = {
    enable = mkEnableOption "Tmpfs as home setup";

    storage = mkOption {
      type = types.str;
      default = null;
      description = "Path of persistent storage";
    };

    persistentDirs = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = "Directories which should be stored in the persistent storage.";
    };

    persistentFiles = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = "Files which should be stored in the persistent storage.";
    };
  };

  config =
    let
      cfg = config.tmpfs-as-home;
      files = cfg.persistentFiles;
      dirs = cfg.persistentDirs;
      storage = cfg.storage;
      storageDirs = map (path: "${storage}/${path}") (unique ((map dirOf files) ++ dirs));
    in
    mkIf cfg.enable {
      # TODO Remove symlinks from the old generation that are not in the new generation
      # like home-manager.
      home.activation.tmpfs-as-home = hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] (
        concatStringsSep "\n" ((
          map (path: "$DRY_RUN_CMD mkdir -p ${escapeShellArg path}") storageDirs
        ) ++ (
          map
            (path: ''
              $DRY_RUN_CMD mkdir -p $(dirname ~/${escapeShellArg path})
              $DRY_RUN_CMD ln -fnTs ${escapeShellArg (storage + "/" + path)} ~/${escapeShellArg path}
            '')
            (files ++ dirs)
        )
        )
      );

      tmpfs-as-home.persistentDirs = [
        ".local/state/home-manager"
      ];
    };
}
