{ ... }:
{
  # SDDM + KDE Wayland Desktop
  services.xserver = {
    enable = true;
    layout = "jp";
    displayManager = {
      # TODO sddm bug https://github.com/NixOS/nixpkgs/issues/152726
      # TODO wayland sddm
      # sddm = {
      #   enable = true;
      #   enableHidpi = true;
      # };
      lightdm.enable = true;
      defaultSession = "plasmawayland";
      autoLogin = {
        enable = true;
        user = "user";
      };
    };
    desktopManager.plasma5 = {
      enable = true;
      supportDDC = true; # experimental external monitor backlight control
      runUsingSystemd = true;
      useQtScaling = true; # HiDPI
    };
    libinput.enable = true;
  };
  hardware.opengl.driSupport32Bit = true; #32bit OpenGL

  # Wayland
  environment.sessionVariables = {
    # SDL
    SDL_VIDEODRIVER = "wayland";
    # Qt
    QT_QPA_PLATFORM = "wayland;xcb";
    # Fix for some Java AWT applications (e.g. Android Studio),
    # use this if they aren't displayed properly:
    _JAVA_AWT_WM_NONREPARENTING = "1";
    # Clutter
    CLUTTER_BACKEND = "wayland";
    # Firefox
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_WEBRENDER = "1";
    # Chromium / Electron (experimental)
    NIXOS_OZONE_WL = "1";
  };

  modules.tmpfs-as-root.persistentDirs = [
    "/var/lib/upower" # battery statistics
  ];
}
