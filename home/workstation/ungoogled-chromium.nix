{ pkgs, ... }:
let
  inherit (builtins) listToAttrs attrNames readDir concatLists;
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
  };

  xdg.configFile =
    let
      extensions = with pkgs.ngkz; [
        chromium-extension-auto-tab-discard
        chromium-extension-clearurls
        chromium-extension-decentraleyes
        chromium-extension-get-rss-feed-url-extension
        chromium-extension-https-everywhere
        chromium-extension-keepassxc-browser
        chromium-extension-mouse-dictionary
        chromium-extension-reddit-enhancement-suite
        chromium-extension-ublacklist
        chromium-extension-ublock0
        chromium-extension-useragent-switcher
        chromium-extension-vue-devtools
      ];
    in
    listToAttrs (
      concatLists (
        map
          (ext:
            map
              (name: {
                name = "chromium/External Extensions/${name}";
                value.source = "${ext}/share/chromium/extensions/${name}";
              })
              (attrNames (readDir "${ext}/share/chromium/extensions"))
          )
          extensions
      )
    );

  home.tmpfs-as-home.persistentDirs = [
    ".config/chromium/Default"
  ];

  home.tmpfs-as-home.persistentFiles = [
    ".config/chromium/Last Version"
  ];
} 
