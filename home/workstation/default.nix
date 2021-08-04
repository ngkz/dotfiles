{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf mkOption types;
in {
  imports = [
    ./direnv.nix
  ];

  options.f2l.workstation = mkOption {
    type = types.bool;
    default = false;
    description = "Whether the host is workstation";
  };

  config = mkIf config.f2l.workstation {

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
    f2l.home.persist.directories = [
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
  };
}
