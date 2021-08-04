{ lib, config, ... }:
let
  inherit (builtins) listToAttrs;
  inherit (lib) mkIf nameValuePair hm concatStringsSep escapeShellArg mkOption
                mkEnableOption types unique;
in {
  options.f2l.home.persist = {
    enable = mkEnableOption "persistent home directory";

    root = mkOption {
      type = types.str;
      default = "/nix/persist${config.home.homeDirectory}";
      description = "Path of persistent storage";
    };

    directories = mkOption {
      type = with types; listOf string;
      default = [];
      description = "Directories which should be stored in the persistent storage.";
    };

    files = mkOption {
      type = with types; listOf string;
      default = [];
      description = "Files which should be stored in the persistent storage.";
    };
  };

  config = let
    cfg = config.f2l.home.persist;
    files = cfg.files;
    dirs = cfg.directories;
    root = cfg.root;
    storageDirs = map (path: "${root}/${path}") (unique ((map dirOf files) ++ dirs));
  in mkIf cfg.enable {
    home.file = listToAttrs (
      map (
        path: nameValuePair path {
          source = config.lib.file.mkOutOfStoreSymlink "${root}/${path}";
        }
      ) (files ++ dirs)
    );

    home.activation.persist = hm.dag.entryAfter ["writeBoundary"] (
      concatStringsSep "\n" (
        map (path: "$DRY_RUN_CMD mkdir -p ${escapeShellArg path}") storageDirs
      )
    );
  };
}
