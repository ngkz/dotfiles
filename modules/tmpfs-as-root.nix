{ pkgs, lib, config, ... }:
let
  inherit (builtins) listToAttrs filter attrNames;
  inherit (lib) nameValuePair hasPrefix removePrefix concatStringsSep
    escapeShellArg filterAttrs mkOption types unique;
in
{
  options.modules.tmpfs-as-root = {
    storage = mkOption {
      type = types.nonEmptyStr;
      default = "/nix/persist";
      description = "Path of persistent storage";
    };

    persistentDirs = mkOption {
      type = with types; listOf string;
      default = [ ];
      description = "Directories which should be stored in the persistent storage.";
    };

    persistentFiles = mkOption {
      type = with types; listOf string;
      default = [ ];
      description = "Files which should be stored in the persistent storage.";
    };
  };

  config =
    let
      cfg = config.modules.tmpfs-as-root;
      files = cfg.persistentFiles;
      dirs = cfg.persistentDirs;
      storage = cfg.storage;
      storageDirs = map (path: storage + path) (unique ((map dirOf files) ++ dirs));
      nonEtcFiles = filter (path: !hasPrefix "/etc/" path) files;
      etcFiles = filter (hasPrefix "/etc/") files;
    in
    {
      # "tmpfs as root" setup
      fileSystems = {
        "/" = {
          device = "none";
          fsType = "tmpfs";
          options = [ "size=2G" "mode=755" "noexec" "nodev" "nosuid" ];
        };

        "/var/log" = {
          device = "${cfg.storage}/var/log";
          fsType = "none";
          options = [ "bind" ];
        };
      };

      environment.etc = listToAttrs (
        map (path: nameValuePair (removePrefix "/etc/" path) { source = storage + path; }) etcFiles
      );

      # TODO Remove symlinks from the old generation that are not in the new generation
      # like home-manager.
      system.activationScripts.tmpfs-as-root.text = concatStringsSep "\n" (
        (
          # create tmpfs-as-home storage directories
          map
            (
              userName:
              let
                user = config.users.users.${userName};
                group = config.users.groups.${user.group};
                homeStorage = config.home-manager.users.${userName}.home.tmpfs-as-home.storage;
              in
              "install -dD -o ${toString user.uid} -g ${toString group.gid} -m 700 ${escapeShellArg homeStorage}"
            )
            (attrNames (filterAttrs (n: v: v ? home.tmpfs-as-home) config.home-manager.users))
        ) ++
        (map (path: "mkdir -p ${escapeShellArg path}") storageDirs) ++
        (map
          (path: ''
            mkdir -p $(dirname ${escapeShellArg path})
            ln -fnTs ${escapeShellArg (storage + path)} ${escapeShellArg path}
          '')
          (nonEtcFiles ++ dirs))
      );
      system.activationScripts.users.deps = [ "tmpfs-as-root" ]; # users snippet creates /var/lib/nixos

      modules.tmpfs-as-root.persistentFiles = [
        "/etc/adjtime"
        "/etc/machine-id"
      ];

      modules.tmpfs-as-root.persistentDirs = [
        "/var/lib/nixos" # NixOS keeps track of historical UIDs in here
        "/var/lib/systemd"
        "/var/tmp"
      ];

      systemd.tmpfiles.rules = [
        "d ${storage}/var/tmp 1777 root root 30d"
        "d ${storage}/var/lib/systemd 0755 root root -"
      ];

      # journalctl: Failed to create parent directoties of /var/lib/systemd/catalog/database: Not a directory
      systemd.services.systemd-journal-catalog-update.preStart = "${pkgs.coreutils}/bin/mkdir -p /var/lib/systemd/catalog";
    };
}
