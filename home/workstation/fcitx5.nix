{ pkgs, ... }:
{
  # Fcitx5 + Mozc IM
  i18n.inputMethod = {
    enabled = "fcitx5";
    # TODO Mozc-ut
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-configtool
      libsForQt5.fcitx5-qt
      fcitx5-gtk
    ];
  };
}
