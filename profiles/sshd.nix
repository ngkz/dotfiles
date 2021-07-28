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

  persist.files = [
    "/etc/ssh/ssh_host_rsa_key"
    "/etc/ssh/ssh_host_rsa_key.pub"
    "/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_ed25519_key.pub"
  ];
}
