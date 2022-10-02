{ pkgs, ... }:
{
  # Fcitx5 + Mozc IM
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      ngkz.fcitx5-mozc-ut
      ngkz.fcitx5-themes
    ];
  };

  xdg.configFile."fcitx5".source = ./config;

  home.tmpfs-as-home.persistentDirs = [
    ".config/mozc"
  ];
}
