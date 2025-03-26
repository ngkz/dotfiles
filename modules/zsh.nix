# zsh nixos integration
{ pkgs, ... }:

{
  users.users.user.shell = pkgs.zsh;

  environment.pathsToLink = [ "/share/zsh" ];

  programs.zsh.enable = true;
}
