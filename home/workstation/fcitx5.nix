{ pkgs, ... }:
{
  # Fcitx5 + Mozc IM
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      my.fcitx5-mozc-ut
    ];
  };
}
