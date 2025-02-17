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

    personalEmail = mkOption {
      type = types.str;
      description = "personal mail address";
    };
  };

  config = {
    personalEmail = rot13 "xa@s2y.pp";

    # automatially trigger X-Restart-Triggers
    systemd.user.startServices = true;
  };
}
