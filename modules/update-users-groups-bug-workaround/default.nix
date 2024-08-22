# XXX temporary workaround for https://github.com/NixOS/nixpkgs/pull/273758
{ config, lib, pkgs, utils, ... }:
let
  inherit (lib) mapAttrsToList;
in
{
  system.activationScripts.users.text =
    with lib;
    let
      cfg = config.users;
      spec = pkgs.writeText "users-groups.json" (builtins.toJSON {
        inherit (cfg) mutableUsers;
        users = mapAttrsToList
          (_: u:
            {
              inherit (u)
                name uid group description home homeMode createHome isSystemUser
                password hashedPasswordFile hashedPassword
                autoSubUidGidRange subUidRanges subGidRanges
                initialPassword initialHashedPassword expires;
              shell = utils.toShellPath u.shell;
            })
          cfg.users;
        groups = attrValues cfg.groups;
      });
    in
    lib.mkForce ''
      install -m 0700 -d /root
      install -m 0755 -d /home

      ${pkgs.perl.withPackages (p: [ p.FileSlurp p.JSON ])}/bin/perl \
      -w ${./update-users-groups.pl} ${spec}
    '';
}
