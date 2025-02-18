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

    gpgFingerprint = mkOption {
      type = types.str;
      description = "persnal gpg key fingerprint";
    };
  };

  config = {
    personalEmail = rot13 "xa@s2y.pp";
    gpgFingerprint = "BC6DCFE03513A9FA4F55D70206B8106665DD36F3";

    # automatially trigger X-Restart-Triggers
    systemd.user.startServices = true;
  };
}
