# home-manager configuration for all users
{ lib, ... }:
let
  inherit (lib) types mkOption;
  inherit (lib.ngkz) rot13;
in
{
  options = {
    systemName = mkOption {
      type = types.str;
      description = "the name of the system";
    };

    personal-email = mkOption {
      type = types.str;
      description = "personal mail address";
      default = rot13 "xa@s2y.pp";
    };
  };

  config = {
    # automatially trigger X-Restart-Triggers
    systemd.user.startServices = true;
  };
}
