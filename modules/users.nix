# User accounts
{ pkgs, ... }:
{
  users = {
    mutableUsers = false;

    users = {
      # disable root login
      root.hashedPassword = "*";

      # define a primary user account
      user = {
        isNormalUser = true;
        uid = 1000;
        extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
        shell = pkgs.zsh;
      };
    };
  };

  # XXX Apply home.sessionPath when logging in via ssh
  programs.zsh.enable = true;

  # XXX Apply home.sessionVariables. Workaround for home-manager #1011
  environment.extraInit = ''
    if [ -e "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
      . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
    fi
  '';

  environment.pathsToLink = [ "/share/zsh" ]; #zsh
}
