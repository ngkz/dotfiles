{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.services.intel-undervolt;
in
{
  options = {
    services.intel-undervolt = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable undervolting for Haswell and newer Intel CPUs.
        '';
      };

      extraConfig = mkOption {
        type = types.str;
        default = "";
        description = "Alternative configuration";
      };
    };
  };

  config = mkIf (cfg.enable) {
    systemd = {
      packages = [ pkgs.my.intel-undervolt ];
      services = {
        intel-undervolt.wantedBy = [
          "multi-user.target"
          "suspend.target"
          "hibernate.target"
          "hybrid-sleep.target"
        ];
        intel-undervolt-loop.wantedBy = [ "multi-user.target" ];
      };
    };
    environment.etc."intel-undervolt.conf" = mkIf (cfg.extraConfig != "") {
      source = pkgs.writeText "intel-undervolt.conf" cfg.extraConfig;
    };

    environment.systemPackages = [ pkgs.my.intel-undervolt ];

    boot.kernelParams = [
      # Kernel 5.9 spams warnings whenever userspace writes to CPU MSRs.
      # See https://github.com/erpalma/throttled/issues/215
      "msr.allow_writes=on"
    ];
  };
}
