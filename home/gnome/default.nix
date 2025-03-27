# GNOME desktop
# See also: modules/gnome.nix
{ pkgs, ... }: {
  imports = [
    ../tmpfs-as-home.nix
  ];

  programs.gnome-shell = {
    enable = true;
    extensions = [
      {
        id = "system-monitor@gnome-shell-extensions.gcampax.github.com";
        package = pkgs.gnome-shell-extensions;
      }
      { package = pkgs.gnomeExtensions.runcat; }
    ];
  };

  dconf.settings = {
    # Shell
    # Night light
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-temperature = 2859;
    };

    "org/gnome/desktop/sound" = {
      allow-volume-above-100-percent = true;
    };

    "org/gnome/desktop/interface" = {
      show-battery-percentage = true;
      clock-show-weekday = true;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing"; # dont suspend when plugged in
    };

    # wallpapers
    "org/gnome/desktop/background" = {
      picture-uri = "file://${./DSC01320.JPG}";
      picture-uri-dark = "file://${./DSC01320.JPG}";
    };

    # search directories
    "org/freedesktop/tracker/miner/files" = {
      index-recursive-directories = [ "&DESKTOP" "&DOCUMENTS" "&MUSIC" "&PICTURES" "&VIDEOS" "/home/user/misc" "/home/user/projects" ];
    };

    "org/gnome/desktop/peripherals/mouse" = {
      speed = 0.6;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      speed = 1.0;
      natural-scroll = false;
    };

    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };

    "org/gnome/desktop/wm/preferences" = {
      resize-with-right-button = true;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "kgx";
      name = "Spawn terminal";
    };

    # RunCat extension
    "/org/gnome/shell/extensions/runcat" = {
      idle-threshold = 1;
    };

    # Nautilus
    "org/gnome/nautilus/icon-view" = {
      default-zoom-level = "small";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
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

      # Loupe
      "image/jpeg" = "org.gnome.Loupe.desktop";
      "image/png" = "org.gnome.Loupe.desktop";
      "image/gif" = "org.gnome.Loupe.desktop";
      "image/webp" = "org.gnome.Loupe.desktop";
      "image/tiff" = "org.gnome.Loupe.desktop";
      "image/x-tga" = "org.gnome.Loupe.desktop";
      "image/vnd-ms.dds" = "org.gnome.Loupe.desktop";
      "image/x-dds" = "org.gnome.Loupe.desktop";
      "image/bmp" = "org.gnome.Loupe.desktop";
      "image/vnd.microsoft.icon" = "org.gnome.Loupe.desktop";
      "image/vnd.radiance" = "org.gnome.Loupe.desktop";
      "image/x-exr" = "org.gnome.Loupe.desktop";
      "image/x-portable-bitmap" = "org.gnome.Loupe.desktop";
      "image/x-portable-graymap" = "org.gnome.Loupe.desktop";
      "image/x-portable-pixmap" = "org.gnome.Loupe.desktop";
      "image/x-portable-anymap" = "org.gnome.Loupe.desktop";
      "image/x-qoi" = "org.gnome.Loupe.desktop";
      "image/svg+xml" = "org.gnome.Loupe.desktop";
      "image/svg+xml-compressed" = "org.gnome.Loupe.desktop";
      "image/avif" = "org.gnome.Loupe.desktop";
      "image/heic" = "org.gnome.Loupe.desktop";
      "image/jxl" = "org.gnome.Loupe.desktop";
    };
  };

  # user icon on lockscreen
  home.file.".face".source = ./icon.jpg;

  home.sessionVariables = {
    # Enable wayland
    # SDL:
    SDL_VIDEODRIVER = "wayland";
    # Fix for some Java AWT applications (e.g. Android Studio),
    # use this if they aren't displayed properly:
    _JAVA_AWT_WM_NONREPARENTING = "1";
    # Clutter:
    CLUTTER_BACKEND = "wayland";
    # Firefox:
    MOZ_ENABLE_WAYLAND = "1";
    # Chromium / Electron (experimental):
    NIXOS_OZONE_WL = "1";
  };

  tmpfs-as-home.persistentDirs = [
    ".cache/tracker3"
    ".local/share/gnome-shell"
  ];
  tmpfs-as-home.persistentFiles = [
    ".config/monitors.xml"
  ];
}
