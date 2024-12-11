{ pkgs, inputs }:
rec {
  sway-systemd = pkgs.callPackage ./sway-systemd {
    inherit (pkgs.python3Packages)
      wrapPython
      dbus-next
      i3ipc
      psutil
      tenacity
      xlib;
  };
  sway-systemd-autostart = sway-systemd.override { autostart = true; };
  sway-im-unwrapped = pkgs.callPackage ./sway-im-unwrapped { };
  sarasa-term-j-nerd-font = pkgs.callPackage ./sarasa-term-j-nerd-font { };
  blobmoji-fontconfig = pkgs.callPackage ./blobmoji-fontconfig { };
  chromium-extension-ublock0 = pkgs.callPackage ./chromium-extension-ublock0 { };
  chromium-extension-keepassxc-browser = pkgs.callPackage ./chromium-extension-keepassxc-browser { };
  crx3-creator = pkgs.python3Packages.callPackage ./crx3-creator { };
  fcitx5-with-addons = pkgs.libsForQt5.callPackage ./fcitx5-with-addons-patched.nix {
    kcmSupport = false;
  };
  fcitx5-themes-candlelight = pkgs.callPackage ./fcitx5-themes-candlelight { };
  gnome-ssh-askpass3 = pkgs.callPackage ./gnome-ssh-askpass3.nix { };
  backup = pkgs.callPackage ./backup { };
  hotkey-scripts = pkgs.callPackage ./hotkey-scripts { };
  freecad-realthunder = pkgs.libsForQt5.callPackage ./freecad-realthunder { };
  vimix-kde = pkgs.callPackage ./vimix-kde { };
  fcitx5-skk = pkgs.libsForQt5.callPackage ./fcitx5-skk {
    inherit skk-dicts;
  };
  skk-dicts = pkgs.callPackage ./skk-dicts { };
  vcr-eas-font = pkgs.callPackage ./vcr-eas-font { };
  scripts = pkgs.callPackage ./scripts { };
  flygrep-vim = pkgs.callPackage ./flygrep-vim { };
  capture-vim = pkgs.callPackage ./capture-vim { };
  ical2org = pkgs.callPackage ./ical2org { };
  wslnotifyd = pkgs.callPackage ./wslnotifyd { };
}
