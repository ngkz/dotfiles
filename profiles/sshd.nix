# Enable the OpenSSH daemon
{ config, pkgs, ... }: 
{
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
    permitRootLogin = "no";
    startWhenNeeded = true;
    ports = [ 35822 ];
  };

  users.users.user.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQUeKD00Z5e9LmeoHR2oqlTP9i3qMLE3Pc/YEfxQoeL Kazutoshi Noguchi"
  ];

  environment.etc = {
    "ssh/ssh_host_rsa_key".source = "/nix/persist/etc/ssh/ssh_host_rsa_key";
    "ssh/ssh_host_rsa_key.pub".source = "/nix/persist/etc/ssh/ssh_host_rsa_key.pub";
    "ssh/ssh_host_ed25519_key".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
    "ssh/ssh_host_ed25519_key.pub".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key.pub";
  };

  systemd.tmpfiles.rules = [
    "d /nix/persist/etc/ssh - - - -"
  ];
}
