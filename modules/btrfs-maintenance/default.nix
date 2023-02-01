{ config, lib, pkgs, ... }: {
  options.modules.btrfs-maintenance.defrag-mounts = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };

  config =
    let
      defrag-mounts = config.modules.btrfs-maintenance.defrag-mounts;
    in
    lib.mkIf (defrag-mounts != [ ]) {
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
          }} ${lib.escapeShellArgs defrag-mounts}";
          Nice = 10;
          IOSchedulingClass = "best-effort";
          IOSchedulingPriority = 7;
        };
      };

      systemd.timers.btrfs-defrag = {
        description = "Timer to defrag btrfs partitions automatically";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "monthly";
          AccuracySec = "1h";
          Persistent = true;
          RandomizedDelaySec = 6000;
        };
      };
    };
}
