{ config, lib, ... }:
let
  inherit (lib) mkOption types mkIf;
in {
  options.f2l.ssd = mkOption {
    type = types.bool;
    default = false;
    description = "Whether the host has SSDs";
  };

  config = mkIf config.f2l.ssd {
    # trim periodically
    services.fstrim.enable = true;

    environment.etc."lvm/lvm.conf".text = ''
      devices {
        issue_discards = 1
      }
    '';
  };
}
