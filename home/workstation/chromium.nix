{ pkgs, ... }:
let
  inherit (builtins) toJSON;
in
{
  programs.chromium = {
    enable = true;
    package = (pkgs.chromium.override {
      commandLineArgs = [
        # XXX ozone-wayland doesn't support text-input-v3 protocol yet
        # https://bugs.chromium.org/p/chromium/issues/detail?id=1039161
        # XXX VA-API hardware video decoding doesn't work on Wayland
        # XXX VA-API hardware video decoding causes slowdown on X11
        #"--ozone-platform=x11"
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

  xdg.configFile."chromium/External Extensions".source =
    let
      env = pkgs.buildEnv {
        name = "chromium-extensions";
        paths = with pkgs.ngkz; [
          chromium-extension-keepassxc-browser
          chromium-extension-ublock0
        ];
        pathsToLink = "/share/chromium/extensions";
      };
    in
    "${env}/share/chromium/extensions";

  xdg.configFile."chromium/NativeMessagingHosts/org.keepassxc.keepassxc_browser.json".text = toJSON {
    allowed_origins = [
      "chrome-extension://aagogodjfilkindafjogmjjpeoflafop/" # chromium-extension-keepassxc-browser
    ];
    name = "org.keepassxc.keepassxc_browser";
    description = "KeePassXC integration with native messaging support";
    path = "${pkgs.keepassxc}/bin/keepassxc-proxy";
    type = "stdio";
  };

  home.tmpfs-as-home.persistentDirs = [
    ".config/chromium/Default"
  ];

  home.tmpfs-as-home.persistentFiles = [
    ".config/chromium/Last Version"
  ];
} 
