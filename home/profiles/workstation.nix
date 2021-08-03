{ pkgs, ... }: {
  imports = [
    ../modules/direnv.nix
  ];

  # XDG user dirs
  xdg.userDirs = {
    enable = true;
    desktop = "$HOME";
    documents = "$HOME/docs";
    download = "$HOME/dl";
    music = "$HOME/music";
    pictures = "$HOME/pics";
    publicShare = "$HOME";
    templates = "$HOME";
    videos = "$HOME/videos";
  };

  # tmpfs as home
  home.persist.directories = [
    # personal files
    "docs"
    "dl"
    "music"
    "pics"
    "videos"
    "projects"
    "work"
    "misc"
  ];

  # Git
  programs.git = {
    enable = true;
    delta.enable = true;
  };

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
    powertop
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
