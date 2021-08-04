{ config, lib, ... }:
let
  inherit (lib) mkOption types mkIf;
in {
  options.f2l.portable = mkOption {
    type = types.bool;
    default = false;
    description = "Whether the host is portable (phone or laptop)";
  };

  config = mkIf config.f2l.portable {
    # better timesync for unstable internet connections
    services.timesyncd.enable = false;
    services.chrony = {
      enable = true;
      directory = "/nix/persist/var/lib/chrony";
    };
  };
}
