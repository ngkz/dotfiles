{ pkgs, ... }:
{
  imports = [
    ./direnv.nix
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
  ];

  # Git
  programs.git = {
    enable = true;
    delta.enable = true;
  };

  home.packages = with pkgs; [
    powertop
  ];
}
