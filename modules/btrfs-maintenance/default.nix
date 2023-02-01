{ config, lib, utils, pkgs, ... }: {
  options.modules.btrfs-maintenance = {
    defragMounts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    fileSystems = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config =
    let
      cfg = config.modules.btrfs-maintenance;
    in
    lib.mkMerge [
      (
        lib.mkIf (cfg.defragMounts != [ ]) {
          # Run btrfs maintenance tasks automatically
          systemd.services.btrfs-defrag = {
            description = "Defrag btrfs partitions";
            unitConfig = {
              ConditionACPower = true;
            };
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pkgs.substituteAll {
            src = ./btrfs-defrag.sh;
            isExecutable = true;
            path = with pkgs; [ coreutils findutils gawk gnused e2fsprogs btrfs-progs ];
            inherit (pkgs) bash;
          }} ${lib.escapeShellArgs cfg.defragMounts}";
              Nice = 19;
              IOSchedulingClass = "idle";
            };
          };

          systemd.timers.btrfs-defrag = {
            description = "Timer to defrag btrfs partitions automatically";
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = "monthly";
              AccuracySec = "1d";
              Persistent = true;
            };
          };
        })
      (lib.mkIf (cfg.fileSystems != [ ]) {
        services.btrfs.autoScrub = {
          enable = true;
          fileSystems = cfg.fileSystems;
        };

        systemd.services =
          let
            scrubService = fs:
              let
                fs' = utils.escapeSystemdPath fs;
              in
              lib.nameValuePair "btrfs-scrub-${fs'}" {
                unitConfig = {
                  ConditionACPower = true;
                };
              };
          in
          lib.listToAttrs (map scrubService cfg.fileSystems);
      })
    ];
}
