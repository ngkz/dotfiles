{ lib, pkgs, ... }:
{
  imports = [
    ./theming.nix
    ./direnv.nix
    ./im
    #./chromium.nix
    ./librewolf
    ./wine.nix
    ./doom-emacs
    ./hyfetch.nix
    # ./gtkcord4.nix
    ./user-dirs.nix
    ./cli-extended.nix
    ./desktop-essential.nix
    ./keepassxc
    ./keepassxc/librewolf.nix
    ./adb.nix
    ./mpv.nix
    ./dev-docs.nix
    ./git.nix
  ];

  # tmpfs as home
  tmpfs-as-home.persistentDirs = [
    # libreoffice
    ".config/libreoffice"
    # transmission
    ".config/transmission"
    # FreeCAD
    ".FreeCAD"
    ".config/FreeCAD"
    # shotcut
    ".config/Meltytech"
    ".local/share/Meltytech/Shotcut"
    # electrum
    ".electrum"
    # platformio
    ".platformio"
    # inkscape
    ".config/inkscape"
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # wine
      "application/x-ms-dos-executable" = "wine.desktop";
    };
  };

  dconf.settings = {
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };
  };

  home.packages = with pkgs; [
    powertop
    tpm2-tools
    efitools
    v4l-utils
    platformio

    dconf-editor
    freecad-wayland
    gimp
    inkscape
    pavucontrol
    libreoffice
    xorg.xlsclients
    transmission_4-gtk
    filezilla
    shotcut
    electrum
    tenacity
    scrcpy
    shortwave
  ];
}
