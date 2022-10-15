{ pkgs, ... }:
let
  inherit (builtins) listToAttrs attrNames readDir concatLists toJSON;
in
{
  programs.chromium = {
    enable = true;
    package = (pkgs.ungoogled-chromium.override {
      commandLineArgs = [
        # XXX ozone-wayland doesn't support text-input-v3 protocol yet
        # https://bugs.chromium.org/p/chromium/issues/detail?id=1039161
        # XXX VA-API hardware video decoding doesn't work on Wayland
        # XXX VA-API hardware video decoding causes slowdown on X11
        "--ozone-platform=x11"
        "--enable-features=VaapiVideoEncoder,VaapiVideoDecoder,CanvasOopRasterization"
        "--use-gl=egl"
        "--enable-oop-rasterization"
        "--enable-raw-draw"

        #"--disable-reading-from-canvas" # Cloudflare doesn't like this
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
      ];
    in
    listToAttrs
      (
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
      ) // {
      "chromium/NativeMessagingHosts/org.keepassxc.keepassxc_browser.json".text = toJSON {
        allowed_origins = [
          "chrome-extension://aagogodjfilkindafjogmjjpeoflafop/" # chromium-extension-keepassxc-browser
        ];
        name = "org.keepassxc.keepassxc_browser";
        description = "KeePassXC integration with native messaging support";
        path = "${pkgs.keepassxc}/bin/keepassxc-proxy";
        type = "stdio";
      };
    };

  home.tmpfs-as-home.persistentDirs = [
    ".config/chromium/Default"
  ];

  home.tmpfs-as-home.persistentFiles = [
    ".config/chromium/Last Version"
  ];
} 
