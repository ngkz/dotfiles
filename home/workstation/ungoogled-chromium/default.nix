{ pkgs, lib, ... }:
let
  extensionsLib = import ./extensions.nix {
    inherit pkgs lib;
  };
  inherit (extensionsLib) zipExtension storeExtension;
in
{
  programs.chromium = {
    enable = true;
    package = (pkgs.ungoogled-chromium.override {
      commandLineArgs = [
        # XXX ozone-wayland doesn't support text-input-v3 protocol yet
        # https://bugs.chromium.org/p/chromium/issues/detail?id=1039161
        #"--ozone-platform-hint=auto"
        # XXX VA-API hardware video decoding doesn't work
        # TODO https://bbs.archlinux.org/viewtopic.php?id=244031&p=27
        "--enable-features=VaapiVideoEncoder,VaapiVideoDecoder,CanvasOopRasterization"
        "--use-gl=egl"
        "--enable-oop-rasterization"
        "--enable-raw-draw"

        "--disable-reading-from-canvas"
        "--ignore-gpu-blocklist"
        "--enable-gpu-rasterization"
        "--disable-gpu-driver-bug-workarounds"
        #"--disable-background-networking"
        "--enable-accelerated-video-decode"
        "--enable-zero-copy"
        "--disable-features=UseChromeOSDirectVideoDecoder"
        "--disable-gpu-memory-buffer-compositor-resources"
        "--disable-gpu-memory-buffer-video-frames"
        "--enable-hardware-overlays"
      ];
    });
    extensions = [
      (zipExtension rec {
        name = "uBlock0";
        version = "1.42.4";
        url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
        sha256 = "1h3ykr06v24d42iywhjrac2j6i63cxi2h3mj3kpyln5q9w2rv3yw";
      })
      (zipExtension rec {
        name = "keepassxc-browser";
        version = "1.7.12";
        url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
        sha256 = "0slrj3p14n2mmp0s3jnrfafc6ahyfrpjf1zp153mnzi7r63m34f6";
      })
      (zipExtension rec {
        name = "auto-tab-discard";
        version = "0.6.1";
        url = "https://github.com/rNeomy/auto-tab-discard/archive/refs/tags/v${version}.zip";
        sha256 = "1q05vq5rk4gg8hrqkbv6kjfp4pfnvdxmmzxz6783fqg7mw4w0yh4";
        root = "auto-tab-discard-${version}/v3";
      })
      (zipExtension rec {
        name = "get-rss-feed-url-extension";
        version = "1.4.1";
        url = "https://github.com/shevabam/get-rss-feed-url-extension/archive/refs/tags/v${version}.zip";
        sha256 = "0qkwv91ad798snlfns680vs3fxqcci90iyxh9v9fbqivmhdgfpmf";
      })
      (zipExtension rec {
        name = "https-everywhere";
        version = "2021.7.13";
        url = "https://github.com/EFForg/https-everywhere/releases/download/${version}/https-everywhere-${version}-edge.zip";
        sha256 = "f346f3ff827fcbf134e9995d73e150f0e72ca6e4cf9092d276fd3d226142a3df";
      })
      # Mouse Dictionary
      (storeExtension {
        id = "dnclbikcihnpjohihfcmmldgkjnebgnj";
        sha256 = "11ch658cs2k9zbzwl8scjwn3rv451ha9fyclvl7c4vz3z53wzb0i";
        version = "1.6.2";
      })
      (zipExtension rec {
        name = "Reddit-Enhancement-Suite";
        version = "5.22.10";
        url = "https://github.com/honestbleeps/Reddit-Enhancement-Suite/releases/download/v${version}/chrome.zip";
        sha256 = "0pdq84zzx1jfncfald0x2aj6wk1d59yvllk2jwa73w716420miim";
      })
      # (gitExtension {
      #   name = "UserAgent-Switcher";
      #   version = "0.4.8";
      #   url = "https://github.com/ray-lothian/UserAgent-Switcher.git";
      #   sha256 = "";
      #   root = "extension/chrome";
      # })
      (zipExtension rec {
        name = "uBlacklist";
        version = "7.6.0";
        url = "https://github.com/iorate/ublacklist/releases/download/v${version}/ublacklist-v${version}-chrome.zip";
        sha256 = "09wz1vm9lp55bxn28q1x7sp5gv4hn3a84rxdh0irrj97xhblbghz";
      })
      # Decentraleyes
      {
        id = "ldpochfccmkkmhdbclfhpagapcfdljkj";
        version = "2.0.17";
        crxPath = builtins.fetchurl {
          url = "https://git.synz.io/Synzvato/decentraleyes/uploads/c6483673bef7c90acb552b66111a3c76/Decentraleyes.v2.0.17-chromium.crx";
          sha256 = "0r7bip4yp3ybcxbm20x89qjhd346pz3b9bkalkjrgwx7q3namzgm";
        };
      }
      #TODO clearurls
      #TODO vue.js devtools
      #TODO User-Agent switcher
    ];
  };

  home.tmpfs-as-home.persistentDirs = [
    ".config/chromium/Default"
  ];

  home.tmpfs-as-home.persistentFiles = [
    ".config/chromium/Last Version"
  ];
}
