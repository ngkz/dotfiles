{ config, pkgs, ... }:
{
  # Sway wayland compositor
  programs.sway = {
    enable = true;
    extraPackages = [];
    extraSessionCommands = ''
      # SDL:
      export SDL_VIDEODRIVER=wayland
      # QT (needs qt5.qtwayland in systemPackages):
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
      # Clutter:
      export CLUTTER_BACKEND=wayland
      # Firefox:
      export MOZ_ENABLE_WAYLAND=1
      export MOZ_WEBRENDER=1
      ${if config.virtualisation.virtualbox.guest.enable then ''
        # Workaround for sway #3814
        export WLR_NO_HARDWARE_CURSORS=1
      '' else ""}
    '';
    wrapperFeatures.gtk = true;
  };

  # XDG portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    gtkUsePortal = true;
  };

  environment.systemPackages = with pkgs; [
    qt5.qtwayland # QT_QPA_PLATFORM=wayland
  ];
}
