{ pkgs, ... }: {
  #TODO: media.ffmpeg.vaapi.enabled

  home.packages = with pkgs; [
    librewolf
  ];

  home.tmpfs-as-home.persistentDirs = [
    ".librewolf"
  ];
}
