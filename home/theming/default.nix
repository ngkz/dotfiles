{ pkgs, ... }:
let
  iniFormat = pkgs.formats.ini { };
  vimix-theme = pkgs.vimix-gtk-themes.override {
    themeVariants = [ "ruby" ];
    colorVariants = [ "dark" ];
    sizeVariants = [ "compact" ];
  };
in
{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark"; # GTK4 dark theme
      enable-animations = true;
      document-font-name = "Sans Serif 9";
      monospace-font-name = "Monospace 9";
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":"; # hide window buttons
    };
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.bibata-extra-cursors;
      name = "Bibata-Original-DarkRed";
    };
    font = {
      name = "Sans-Serif";
      size = 9;
    };
    theme = {
      package = vimix-theme;
      name = "vimix-dark-compact-ruby";
    };
    iconTheme = {
      package = pkgs.vimix-icon-theme;
      name = "Vimix-Ruby-dark";
    };
    gtk3.bookmarks = [
      "file:///home/user/docs docs"
      "file:///home/user/pics pics"
      "file:///home/user/music music"
      "file:///home/user/videos videos"
      "file:///home/user/dl dl"
      "file:///home/user/projects projects"
      "file:///home/user/work work"
      "file:///home/user/misc misc"
    ];
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  xdg.configFile."gtk-4.0/assets".source = "${vimix-theme}/share/themes/vimix-dark-compact-ruby/gtk-4.0/assets";
  xdg.configFile."gtk-4.0/gtk.css".source = "${vimix-theme}/share/themes/vimix-dark-compact-ruby/gtk-4.0/gtk.css";
  xdg.configFile."gtk-4.0/gtk-dark.css".source = "${vimix-theme}/share/themes/vimix-dark-compact-ruby/gtk-4.0/gtk-dark.css";

  home.sessionVariables.QT_QPA_PLATFORMTHEME = "qt5ct";
  xdg.configFile."qt5ct/qt5ct.conf".source = ./qt5ct.conf;

  xdg.configFile."Kvantum/VimixRuby".source = "${pkgs.ngkz.vimix-kde}/share/Kvantum/VimixRuby";
  xdg.configFile."Kvantum/kvantum.kvconfig".source = iniFormat.generate "kvantum.kvconfig" {
    General.theme = "VimixRubyDark";
  };

  home.packages = with pkgs; [
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
  ];
}
