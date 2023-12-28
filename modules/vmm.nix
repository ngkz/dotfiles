{ config, lib, pkgs, ... }: {
  users.users.user.extraGroups = [ "vboxusers" ];

  environment.systemPackages = with pkgs; [
    vagrant
  ];

  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };
}
