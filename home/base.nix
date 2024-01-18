# home-manager configuration for all users
{ pkgs, lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  options.systemName = mkOption {
    type = types.str;
    description = "the name of the system";
  };

  config = {
    # automatially trigger X-Restart-Triggers
    systemd.user.startServices = true;
  };
}
