{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "vagrant";
  home.homeDirectory = "/home/vagrant";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  systemName = "kali";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    libreoffice
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  systemd.user.systemctlPath = "/usr/bin/systemctl";

  # import nix environment variables when ssh <command>
  programs.zsh.envExtra = ''
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  '';

  xsession = {
    enable = true;
    windowManager.command = "x-session-manager";
    profileExtra = ''
      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    '';
  };

  imports = [
    ../../home/base.nix
    ../../home/cli-base.nix
    ../../home/hacking
    ../../home/im
  ];
}
