{ config, pkgs, lib, ... }:
let
  inherit (builtins) toString;
  inherit (lib) mkOption types optionalString makeBinPath;

  cfg = config.undervolt;
in {
  options.undervolt = {
    cpu = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "CPU voltage offset (mV)";
    };
    gpu = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "GPU voltage offset (mV)";
    };
    cpuCache = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "CPU cache voltage offset (mV)";
    };
    gpuUnslice = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "GPU unslice voltage offset (mV)";
    };
    systemAgent = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "System Agent voltage offset (mV)";
    };

    shortTermPowerLimit = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Short term power limit (W)";
    };
    shortTermPowerLimitTime = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Short term power limit time window (us)";
    };
    longTermPowerLimit = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Long term power limit (W)";
    };
    longTermPowerLimitTime = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Short term power limit time window (us)";
    };

    tjoffset = mkOption {
      type = types.nullOr types.int;
      default = null;
      description =
        "Temperature limit (C). offset from critical temperature (100C)";
    };
  };

  config = {
    systemd.services.undervolt = let
      optional = x: optionalString (x != null) (toString x);
      script = pkgs.substituteAll {
        src = ./undervolt.sh;
        isExecutable = true;
        path = makeBinPath (with pkgs; [ msr-tools ]);
        inherit (pkgs) bash;
        cpu = optional cfg.cpu;
        gpu = optional cfg.gpu;
        cpuCache = optional cfg.cpuCache;
        gpuUnslice = optional cfg.gpuUnslice;
        systemAgent = optional cfg.systemAgent;
        shortTermPowerLimit = optional cfg.shortTermPowerLimit;
        shortTermPowerLimitTime = optional cfg.shortTermPowerLimitTime;
        longTermPowerLimit = optional cfg.longTermPowerLimit;
        longTermPowerLimitTime = optional cfg.longTermPowerLimitTime;
        tjoffset = optional cfg.tjoffset;
      };
    in {
      description = "Intel Undervolting Service";

      # Apply undervolt on boot, nixos generation switch and resume
      wantedBy = [ "multi-user.target" "post-resume.target" ];
      after =
        [ "post-resume.target" ]; # Not sure why but it won't work without this

      serviceConfig = {
        Type = "oneshot";
        Restart = "no";
        ExecStart = script;
      };
    };

    boot.kernelParams = [
      # Kernel 5.9 spams warnings whenever userspace writes to CPU MSRs.
      # See https://github.com/erpalma/throttled/issues/215
      "msr.allow_writes=on"
    ];
  };
}
