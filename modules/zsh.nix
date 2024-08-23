# Ugly hacks zsh needs
{ pkgs, ... }:

{
  users.users.user.shell = pkgs.zsh;

  environment.pathsToLink = [ "/share/zsh" ];

  # XXX Apply home.sessionPath when logging in via ssh
  programs.zsh.enable = true;

  # XXX Apply home.sessionVariables. Workaround for home-manager #1011
  environment.extraInit = ''
    if [ -e "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
      . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
    fi
  '';
}
