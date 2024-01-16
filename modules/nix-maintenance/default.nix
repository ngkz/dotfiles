{ pkgs, ... }: {
  systemd.services.nix-maintenance = {
    description = "Nix maintenance tasks";
    unitConfig = {
      ConditionACPower = true;
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.substituteAll {
        src = ./nix-maintenance.sh;
        isExecutable = true;
        path = with pkgs; [ coreutils nix util-linux findutils e2fsprogs gnused gawk btrfs-progs duperemove gnugrep ];
        inherit (pkgs) bash;
      }}";
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };
  };

  systemd.timers.nix-maintenance = {
    description = "Timer to run nix maintainance tasks automatically";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      AccuracySec = "1h";
      Persistent = true;
      RandomizedDelaySec = 6000;
    };
  };

  tmpfs-as-root.persistentDirs = [
    "/var/cache/nix-maintenance"
  ];
}
