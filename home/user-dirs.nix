# User directories
{ config, lib, ... }:
let
  inherit (lib) mkIf strings;
  dirs = [
    "docs"
    "dl"
    "music"
    "pics"
    "videos"
    "projects"
    "misc"
  ];
in

{
  imports = [
    ./tmpfs-as-home.nix
  ];

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

  tmpfs-as-home.persistentDirs = dirs;

  home.activation.createUserDirectories = mkIf (!config.tmpfs-as-home.enable) (
    let
      mkdir =
        (dir: let path = "${config.home.homeDirectory}/${dir}"; in ''[[ -L "${path}" ]] || run mkdir -p $VERBOSE_ARG "${path}"'');
    in
    lib.hm.dag.entryAfter [ "linkGeneration" ]
      (strings.concatMapStringsSep "\n" mkdir dirs)
  );
}
