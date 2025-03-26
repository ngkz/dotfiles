{ pkgs, lib, ... }:
let
  accentColor = "red";
  iconTheme = "Adwaita-${accentColor}";
in
{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark"; # GTK4 dark theme
      accent-color = accentColor;
      enable-animations = true;
      document-font-name = "Sans Serif 9";
      monospace-font-name = "Monospace 9";
    };
  };

  gtk = {
    enable = true;
    font = {
      name = "Sans-Serif";
      size = 9;
    };
    iconTheme = {
      package = pkgs.ngkz.adwaita-colors-icon-theme;
      name = iconTheme;
    };
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3";
    };
    gtk3 = {
      # https://github.com/lassekongo83/adw-colors/tree/main/accent-color-change
      extraCss = ''
        @define-color accent_blue #3584e4;
        @define-color accent_teal #2190a4;
        @define-color accent_green #3a944a;
        @define-color accent_yellow #c88800;
        @define-color accent_orange #ed5b00;
        @define-color accent_red #e62d42;
        @define-color accent_pink #d56199;
        @define-color accent_purple #9141ac;
        @define-color accent_slate #6f8396;
        @define-color accent_bg_color @accent_${accentColor};
        @define-color accent_color @accent_bg_color;
      '';
      extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };
    gtk4.extraConfig = {
      gtk-theme-name = "Adwaita-dark";
    };
  };

  xdg.enable = true;

  home.sessionVariables.QT_QPA_PLATFORMTHEME = "qt5ct";
  xdg.configFile."qt5ct/qt5ct.conf".text = ''
    [Appearance]
    color_scheme_path=${pkgs.libsForQt5.qt5ct}/share/qt5ct/colors/airy.conf
    custom_palette=false
    standard_dialogs=default
    icon_theme=${iconTheme}
    style=kvantum

    [Fonts]
    fixed="Monospace,9,-1,5,50,0,0,0,0,0"
    general="Sans Serif,9,-1,5,50,0,0,0,0,0"

    [Interface]
    activate_item_on_single_click=1
    buttonbox_layout=3
    cursor_flash_time=1000
    dialog_buttons_have_icons=1
    double_click_interval=400
    gui_effects=@Invalid()
    keyboard_scheme=2
    menus_have_icons=true
    show_shortcuts_in_context_menus=true
    stylesheets=@Invalid()
    toolbutton_style=4
    underline_shortcut=1
    wheel_scroll_lines=3

    [SettingsWindow]
    geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\x5\0\0\0\0\0\0\0\a{\0\0\x5\x83\0\0\x5\0\0\0\0\0\0\0\a\xde\0\0\x2\x95\0\0\0\x1\x2\0\0\0\n\0\0\0\x5\0\0\0\0\0\0\0\a{\0\0\x5\x83)

    [Troubleshooting]
    force_raster_widgets=1
    ignored_applications=@Invalid()
  '';

  # https://github.com/lassekongo83/adw-colors/tree/main/accent-color-change
  xdg.configFile."gtk-4.0/gtk.css".text = lib.mkForce ''
    :root {
      --accent-color: var(--accent-bg-color);
      --accent-bg-color: var(--accent-${accentColor});
    }
  '';

  xdg.configFile."Kvantum/Colloid".source = "${pkgs.colloid-kde}/share/Kvantum/Colloid";
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=ColloidDark
  '';

  home.packages = with pkgs; [
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    colloid-kde
  ];
}
