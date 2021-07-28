{ lib, config, ... }:

with lib;

{
  options.persist = {
    root = mkOption {
      type = types.str;
      default = "/nix/persist";
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
    cfg = config.persist;
    files = cfg.files;
    dirs = cfg.directories;
    root = cfg.root;
    storageDirs = map (path: root + path) (unique ((map dirOf files) ++ dirs));
    nonEtcFiles = filter (path: !hasPrefix "/etc/" path) files;
    etcFiles = filter (hasPrefix "/etc/") files;
  in {
    environment.etc = listToAttrs (
      map (path: nameValuePair (removePrefix "/etc/" path) { source = root + path; }) etcFiles
    );

    # TODO Remove symlinks from the old generation that are not in the new generation
    # like home-manager.
    system.activationScripts.persist.text = concatStringsSep "\n" (
      (
        map (
          userName: let
            user = config.users.users.${userName};
            group = config.users.groups.${user.group};
            homeStorage = config.home-manager.users.${userName}.home.persist.root;
          in
            "install -dD -o ${toString user.uid} -g ${toString group.gid} -m 700 ${escapeShellArg homeStorage}"
        ) (attrNames (filterAttrs (n: v: v.home.persist.enable or false) config.home-manager.users))
      ) ++
      (map (path: "mkdir -p ${escapeShellArg path}") storageDirs) ++
      (map (path: "ln -fs ${escapeShellArg (root + path)} ${escapeShellArg path}") (nonEtcFiles ++ dirs))
    );
  };
}
