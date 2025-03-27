{ pkgs, inputs }:
rec {
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
  fcitx5-skk = pkgs.libsForQt5.callPackage ./fcitx5-skk {
    inherit skk-dicts;
  };
  skk-dicts = pkgs.callPackage ./skk-dicts { };
  vcr-eas-font = pkgs.callPackage ./vcr-eas-font { };
  flygrep-vim = pkgs.callPackage ./flygrep-vim { };
  capture-vim = pkgs.callPackage ./capture-vim { };
  ical2org = pkgs.callPackage ./ical2org { };
  wslnotifyd = pkgs.callPackage ./wslnotifyd { };
  avr-ghidra-helpers = pkgs.callPackage ./avr-ghidra-helpers { };
  adwaita-colors-icon-theme = pkgs.callPackage ./adwaita-colors-icon-theme { };
}
