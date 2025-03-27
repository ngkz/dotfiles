{ lib, pkgs, ... }:
{
  imports = [
    ./theming.nix
    ./direnv.nix
    ./im
    #./chromium.nix
    ./syncthing
    ./librewolf
    ./wine.nix
    ./doom-emacs
    ./hyfetch.nix
    # ./gtkcord4.nix
    ./signal
    ./user-dirs.nix
    ./foot.nix
    ./cli-extended.nix
    ./desktop-essential.nix
    ./gpg
    ./ssh.nix
    ./keepassxc
    ./keepassxc/librewolf.nix
    ./adb.nix
    ./mpv.nix
  ];

  # tmpfs as home
  tmpfs-as-home.persistentDirs = [
    # tauon
    ".local/share/TauonMusicBox"
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
  ];

  # patch neovim desktop entry
  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    exec = "${pkgs.foot}/bin/foot -- nvim";
    terminal = false;
    icon = "nvim";
    startupNotify = false;
    mimeType = [
      "text/english"
      "text/plain"
      "text/x-makefile"
      "text/x-c++hdr"
      "text/x-c++src"
      "text/x-chdr"
      "text/x-csrc"
      "text/x-java"
      "text/x-moc"
      "text/x-pascal"
      "text/x-tcl"
      "text/x-tex"
      "application/x-shellscript"
      "text/x-c"
      "text/x-c++"
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Nemo
      "inode/directory" = "nemo.desktop";

      # Evince
      "application/vnd.comicbook-rar" = "org.gnome.Evince.desktop";
      "application/vnd.comicbook+zip" = "org.gnome.Evince.desktop";
      "application/x-cb7" = "org.gnome.Evince.desktop";
      "application/x-cbr" = "org.gnome.Evince.desktop";
      "application/x-cbt" = "org.gnome.Evince.desktop";
      "application/x-cbz" = "org.gnome.Evince.desktop";
      "application/x-ext-cb7" = "org.gnome.Evince.desktop";
      "application/x-ext-cbr" = "org.gnome.Evince.desktop";
      "application/x-ext-cbt" = "org.gnome.Evince.desktop";
      "application/x-ext-cbz" = "org.gnome.Evince.desktop";
      "application/x-ext-djv" = "org.gnome.Evince.desktop";
      "application/x-ext-djvu" = "org.gnome.Evince.desktop";
      "image/vnd.djvu" = "org.gnome.Evince.desktop";
      "application/x-bzdvi" = "org.gnome.Evince.desktop";
      "application/x-dvi" = "org.gnome.Evince.desktop";
      "application/x-ext-dvi" = "org.gnome.Evince.desktop";
      "application/x-gzdvi" = "org.gnome.Evince.desktop";
      "application/pdf" = "org.gnome.Evince.desktop";
      "application/x-bzpdf" = "org.gnome.Evince.desktop";
      "application/x-ext-pdf" = "org.gnome.Evince.desktop";
      "application/x-gzpdf" = "org.gnome.Evince.desktop";
      "application/x-xzpdf" = "org.gnome.Evince.desktop";
      "application/postscript" = "org.gnome.Evince.desktop";
      "application/x-bzpostscript" = "org.gnome.Evince.desktop";
      "application/x-gzpostscript" = "org.gnome.Evince.desktop";
      "application/x-ext-eps" = "org.gnome.Evince.desktop";
      "application/x-ext-ps" = "org.gnome.Evince.desktop";
      "image/x-bzeps" = "org.gnome.Evince.desktop";
      "image/x-eps" = "org.gnome.Evince.desktop";
      "image/x-gzeps" = "org.gnome.Evince.desktop";
      "application/oxps" = "org.gnome.Evince.desktop";
      "application/vnd.ms-xpsdocument" = "org.gnome.Evince.desktop";

      # eog
      "image/bmp" = "org.gnome.eog.desktop";
      "image/gif" = "org.gnome.eog.desktop";
      "image/jpeg" = "org.gnome.eog.desktop";
      "image/jpg" = "org.gnome.eog.desktop";
      "image/pjpeg" = "org.gnome.eog.desktop";
      "image/png" = "org.gnome.eog.desktop";
      "image/tiff" = "org.gnome.eog.desktop";
      "image/webp" = "org.gnome.eog.desktop";
      "image/x-bmp" = "org.gnome.eog.desktop";
      "image/x-gray" = "org.gnome.eog.desktop";
      "image/x-icb" = "org.gnome.eog.desktop";
      "image/x-ico" = "org.gnome.eog.desktop";
      "image/x-png" = "org.gnome.eog.desktop";
      "image/x-portable-anymap" = "org.gnome.eog.desktop";
      "image/x-portable-bitmap" = "org.gnome.eog.desktop";
      "image/x-portable-graymap" = "org.gnome.eog.desktop";
      "image/x-portable-pixmap" = "org.gnome.eog.desktop";
      "image/x-xbitmap" = "org.gnome.eog.desktop";
      "image/x-xpixmap" = "org.gnome.eog.desktop";
      "image/x-pcx" = "org.gnome.eog.desktop";
      # "image/svg+xml" = "org.gnome.eog.desktop";
      # "image/svg+xml-compressed" = "org.gnome.eog.desktop";
      "image/vnd.wap.wbmp" = "org.gnome.eog.desktop";
      "image/x-icns" = "org.gnome.eog.desktop";

      # inkscape
      "image/svg+xml" = "org.inkscape.Inkscape.desktop";
      "image/svg+xml-compressed" = "org.inkscape.Inkscape.desktop";
      "application/vnd.corel-draw" = "org.inkscape.Inkscape.desktop";
      "application/illustrator" = "org.inkscape.Inkscape.desktop";
      "image/cgm" = "org.inkscape.Inkscape.desktop";
      "image/x-wmf" = "org.inkscape.Inkscape.desktop";
      "application/x-xccx" = "org.inkscape.Inkscape.desktop";
      "application/x-xcgm" = "org.inkscape.Inkscape.desktop";
      "application/x-xcdt" = "org.inkscape.Inkscape.desktop";
      "application/x-xsk1" = "org.inkscape.Inkscape.desktop";
      "application/x-xcmx" = "org.inkscape.Inkscape.desktop";
      "image/x-xcdr" = "org.inkscape.Inkscape.desktop";
      "application/visio" = "org.inkscape.Inkscape.desktop";
      "application/x-visio" = "org.inkscape.Inkscape.desktop";
      "application/visio.drawing" = "org.inkscape.Inkscape.desktop";
      "application/vsd" = "org.inkscape.Inkscape.desktop";
      "application/x-vsd" = "org.inkscape.Inkscape.desktop";
      "image/x-vsd" = "org.inkscape.Inkscape.desktop";

      # neovim
      "text/english" = "nvim.desktop";
      "text/plain" = "nvim.desktop";
      "text/x-makefile" = "nvim.desktop";
      "text/x-c++hdr" = "nvim.desktop";
      "text/x-c++src" = "nvim.desktop";
      "text/x-chdr" = "nvim.desktop";
      "text/x-csrc" = "nvim.desktop";
      "text/x-java" = "nvim.desktop";
      "text/x-moc" = "nvim.desktop";
      "text/x-pascal" = "nvim.desktop";
      "text/x-tcl" = "nvim.desktop";
      "text/x-tex" = "nvim.desktop";
      "application/x-shellscript" = "nvim.desktop";
      "text/x-c" = "nvim.desktop";
      "text/x-c++" = "nvim.desktop";

      # wine
      "application/x-ms-dos-executable" = "wine.desktop";
    };
  };

  dconf.settings = {
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };

    # nemo
    "org/cinnamon/desktop/applications/terminal" = {
      exec = "foot";
      exec-args = "--";
    };

    "org/nemo/list-view" = {
      default-column-order = [ "name" "size" "type" "date_modified" "octal_permissions" "mime_type" "date_accessed" "group" "permissions" "date_created_with_time" "date_created" "where" "owner" "detailed_type" "date_modified_with_time" ];
      default-visible-columns = [ "name" "size" "type" "date_modified" "permissions" ];
    };

    "org/nemo/preferences" = {
      date-format = "iso";
      quick-renames-with-pause-in-between = true;
      show-advanced-permissions = true;
      thumbnail-limit = lib.hm.gvariant.mkUint64 1073741824;
    };

    "org/nemo/preferences/menu-config" = {
      background-menu-open-as-root = false;
      selection-menu-open-as-root = false;
    };

    "org/nemo/window-state" = {
      sidebar-bookmark-breakpoint = 8;
    };

    # eog
    "org/gnome/eog/ui" = {
      sidebar = false;
    };
  };

  home.packages = with pkgs; [
    powertop
    tpm2-tools
    efitools
    v4l-utils
    platformio

    dconf-editor
    gnome-font-viewer
    freecad-wayland
    gimp
    gscan2pdf # scanning tool
    eog
    inkscape
    tauon
    pavucontrol
    gnome-clocks
    #wxmaxima
    libreoffice
    xorg.xlsclients
    nemo
    ffmpegthumbnailer #video thumbnailer
    totem #audio/video thumbnailer
    gnome-disk-utility
    file-roller
    evince #pdf viewer/thumbnailer
    transmission_4-gtk
    filezilla
    shotcut
    vlc
    wireshark
    electrum
    tenacity
    scrcpy
  ];
}
