{ pkgs, inputs }:
{
  sway-systemd = pkgs.callPackage ./sway-systemd { };
  sway-im-unwrapped = pkgs.callPackage ./sway-im-unwrapped { };
  fcitx5-mozc-ut = pkgs.callPackage ./fcitx5-mozc-ut { };
  sarasa-term-j-nerd-font = pkgs.callPackage ./sarasa-term-j-nerd-font { };
  blobmoji-fontconfig = pkgs.callPackage ./blobmoji-fontconfig { };
  chromium-extension-ublock0 = pkgs.callPackage ./chromium-extension-ublock0 { };
  chromium-extension-keepassxc-browser = pkgs.callPackage ./chromium-extension-keepassxc-browser { };
  crx3-creator = pkgs.python3Packages.callPackage ./crx3-creator { };
  fcitx5-with-addons = pkgs.libsForQt5.callPackage ./fcitx5-with-addons-patched.nix {
    kcmSupport = false;
  };
  fcitx5-themes = pkgs.callPackage ./fcitx5-themes { };
  gnome-ssh-askpass3 = pkgs.callPackage ./gnome-ssh-askpass3.nix { };
  # XXX use main repo package after NixOS 21.11 upgrade
  swaynotificationcenter-unstable = pkgs.callPackage "${inputs.nixpkgs-unstable}/pkgs/applications/misc/swaynotificationcenter/default.nix" { };
  hyfetch-unstable = pkgs.python3Packages.callPackage "${inputs.nixpkgs-unstable}/pkgs/tools/misc/hyfetch/default.nix" { };

  backup = pkgs.callPackage ./backup { };
}
