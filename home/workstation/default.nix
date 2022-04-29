{ pkgs, ... }:
{
  imports = [
    ./direnv.nix
  ];

  # XDG user dirs
  xdg.userDirs = {
    enable = true;
    desktop = "$HOME/desktop";
    documents = "$HOME/docs";
    download = "$HOME/dl";
    music = "$HOME/music";
    pictures = "$HOME/pics";
    publicShare = "$HOME";
    templates = "$HOME";
    videos = "$HOME/videos";
  };

  # tmpfs as home
  home.tmpfs-as-home.persistentDirs = [
    # personal files
    "docs"
    "dl"
    "music"
    "pics"
    "videos"
    "projects"
    "work"
    "misc"
    "desktop"
  ];

  # Git
  programs.git = {
    enable = true;
    delta.enable = true;
  };


  #TODO
  programs.firefox.enable = true;
  #programs.chromium = {
  #  enable = true;
  #  package = pkgs.ungoogled-chromium;
  #};

  home.packages = with pkgs; [
    wl-clipboard
    xdg-utils
    powertop
    efibootmgr

    freecad
    gimp
    keepassxc
  ];
}
