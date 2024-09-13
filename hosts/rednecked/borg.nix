{ lib, pkgs,  ... }:

let
  repo = "/var/spinningrust/borg";
in
{
  users.groups.borg = { };
  users.users.borg = {
    description = "borg server user";
    group = "borg";
    isSystemUser = true;
    home = repo;
    openssh.authorizedKeys.keys = [
      "command=\"borg serve --restrict-to-path ${repo}\",restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQUeKD00Z5e9LmeoHR2oqlTP9i3qMLE3Pc/YEfxQoeL Kazutoshi Noguchi"
    ];
    useDefaultShell = true;
  };

  services.openssh.extraConfig = lib.mkOrder 2000 ''
    Match User borg
      ClientAliveInterval 10
      ClientAliveCountMax 30
  '';

  environment.systemPackages = with pkgs; [
    borgbackup
  ];
}
