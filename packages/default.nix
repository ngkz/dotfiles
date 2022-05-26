{ pkgs }:
let
  nodePackages = import ./nodePackages {
    inherit pkgs;
    inherit (pkgs) system nodejs;
  };
in
{
  sway-systemd = pkgs.callPackage ./sway-systemd { };
  sway-im-unwrapped = pkgs.callPackage ./sway-im-unwrapped { };
  fcitx5-mozc-ut = pkgs.callPackage ./fcitx5-mozc-ut { };
  intel-undervolt = pkgs.callPackage ./intel-undervolt { };
  sarasa-term-j-nerd-font = pkgs.callPackage ./sarasa-term-j-nerd-font { };
  blobmoji-fontconfig = pkgs.callPackage ./blobmoji-fontconfig { };
  chromium-extension-ublock0 = pkgs.callPackage ./chromium-extension-ublock0 { };
  chromium-extension-keepassxc-browser = pkgs.callPackage ./chromium-extension-keepassxc-browser { };
  chromium-extension-auto-tab-discard = pkgs.callPackage ./chromium-extension-auto-tab-discard { };
  chromium-extension-get-rss-feed-url-extension = pkgs.callPackage ./chromium-extension-get-rss-feed-url-extension { };
  chromium-extension-https-everywhere = pkgs.callPackage ./chromium-extension-https-everywhere { };
  chromium-extension-mouse-dictionary = pkgs.callPackage ./chromium-extension-mouse-dictionary { };
  chromium-extension-reddit-enhancement-suite = pkgs.callPackage ./chromium-extension-reddit-enhancement-suite { };
  chromium-extension-useragent-switcher = pkgs.callPackage ./chromium-extension-useragent-switcher { };
} // nodePackages
