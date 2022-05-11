{ pkgs, ... }:
{
  # Sway configuration
  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = false; # XXX workaround for home-manager #2806
    package = null; # use system sway package
    config = {
      terminal = "foot";
    };
    extraConfig = ''
      # XXX workaround for home-manager #2806
      include ${pkgs.my.sway-systemd}/etc/sway/config.d/10-systemd-session.conf
    '';
  };

  # XXX workaround for home-manager #2806
  home.packages = [ pkgs.my.sway-systemd ];
}
