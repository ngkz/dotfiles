{ pkgs, ... }:
{
  # Sway configuration
  wayland.windowManager.sway = {
    enable = true;
    package = null; # use system sway package
    config = {
      terminal = "foot";
    };
  };

  #TODO
  programs.firefox.enable = true;
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
  };

  programs.foot.enable = true;
  programs.zathura.enable = true; #PDF viewer

  home.packages = with pkgs; [
    wl-clipboard
    xdg-utils

    gnome.dconf-editor
    dmenu
    freecad
    gimp
    gscan2pdf #scanning tool
    imv
    keepassxc
    lollypop
    wdisplays
    xfce.thunar
    xfce.thunar-archive-plugin
  ];
}
