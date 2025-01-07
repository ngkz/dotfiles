# Enable the OpenSSH daemon
{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption types mkIf;

  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQUeKD00Z5e9LmeoHR2oqlTP9i3qMLE3Pc/YEfxQoeL Kazutoshi Noguchi"
  ];
in
{
  options.modules.sshd.allowRootLogin = mkOption {
    type = types.bool;
    default = false;
  };

  config = {
    services.openssh = {
      enable = true;
      package = pkgs.openssh_hpn;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = if config.modules.sshd.allowRootLogin then "prohibit-password" else "no";
      };
      startWhenNeeded = true;
    };

    users.users.user.openssh.authorizedKeys.keys = keys;
    users.users.root.openssh.authorizedKeys.keys = mkIf (config.modules.sshd.allowRootLogin) keys;

    tmpfs-as-root.persistentFiles = [
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };
}
