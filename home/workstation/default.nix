{ lib, config, pkgs, ... }:
let
  inherit (lib.ngkz) rot13;
  iniFormat = pkgs.formats.ini { };
  paplay = "${pkgs.pulseaudio}/bin/paplay";
in
{
  imports = [
    ./direnv.nix
    ./fcitx5
    ./ungoogled-chromium.nix
    ./syncthing.nix
    ./luakit
  ];

  # XDG user dirs
  xdg.userDirs = {
    enable = true;
    desktop = "$HOME";
    documents = "$HOME/docs";
    download = "$HOME/dl";
    music = "$HOME/music";
    pictures = "$HOME/pics";
    publicShare = "$HOME";
    templates = "$HOME";
    videos = "$HOME/videos";
  };

  # tmpfs as home
  home.tmpfs-as-home.persistentDirs = [
    # personal files
    "docs"
    "dl"
    "music"
    "pics"
    "videos"
    "projects"
    "work"
    "misc"
    # adb
    ".android"
  ];

  # Git
  programs.git = {
    enable = true;
    delta.enable = true;
    userName = "Kazutoshi Noguchi";
    userEmail = rot13 "abthpuv.xnmhgbfv+Am0Gwsg4@tznvy.pbz";
    signing.key = "BC6DCFE03513A9FA4F55D70206B8106665DD36F3";
    extraConfig = {
      init.defaultBranch = "main";
      diff.tool = "nvimdiff";
      merge.tool = "nvimdiff";
    };
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Monospace:size=10.5";
        dpi-aware = "no";
      };

      bell = {
        urgent = "yes";
        command = "${paplay} ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/complete.oga";
        command-focused = "yes";
      };

      scrollback = {
        lines = 65536;
      };

      colors = {
        # Base16 Monokai
        # Author: Wimer Hazenberg (http://www.monokai.nl)
        foreground = "f8f8f2";
        background = "272822";
        alpha = 0.8;

        # 16 color space
        # Black, Gray, Silver, White
        regular0 = "272822";
        bright0 = "75715e";
        regular7 = "f8f8f2";
        bright7 = "f9f8f5";

        # Red
        regular1 = "f92672";
        bright1 = "f92672";

        # Green
        regular2 = "a6e22e";
        bright2 = "a6e22e";

        # Yellow
        regular3 = "f4bf75";
        bright3 = "f4bf75";

        # Blue
        regular4 = "66d9ef";
        bright4 = "66d9ef";

        # Purple
        regular5 = "ae81ff";
        bright5 = "ae81ff";

        # Teal
        regular6 = "a1efe4";
        bright6 = "a1efe4";

        # Extra colors
        "16" = "fd971f";
        "17" = "cc66ee";
        "18" = "383838";
        "19" = "49483e";
        "20" = "a59f85";
        "21" = "f5f4f1";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };
  };

  programs.zathura.enable = true; #PDF viewer

  #nm-applet
  services.network-manager-applet.enable = true;
  xsession.preferStatusNotifierItems = true;

  services.blueman-applet.enable = true;

  #ssh
  programs.ssh = {
    enable = true;
    serverAliveInterval = 60;
    #https://qiita.com/tango110/items/c8194d43b46fa2a712d1
    extraConfig = ''
      IPQoS none
    '';
    matchBlocks = {
      "github.com" = {
        user = "git";
      };
      "gitlab.com" = {
        user = "git";
      };
      niwase = {
        hostname = rot13 "gfhxhon.avjnfr.arg";
        user = "ngkz";
        port = 49224;
      };
      peregrine = {
        hostname = "peregrine.local";
        user = "user";
        port = 35822;
      };
      prairie = {
        hostname = "prairie.local";
        user = "user";
        port = 35822;
      };
      seychelles = {
        hostname = "seychelles.local";
        user = "manjaro";
        port = 35822;
      };
      laggar = {
        hostname = "laggar.local";
        user = "pi";
      };
      "${rot13 "vsp-agak-abqr1"}" = {
        hostname = "172.16.34.2";
        user = "root";
      };
      "${rot13 "vsp-agak-piz1"}" = {
        hostname = "172.16.34.3";
        user = "nutanix";
      };
      "${rot13 "vsp-agak-abqr2"}" = {
        hostname = "172.16.34.4";
        user = "root";
      };
      "${rot13 "vsp-agak-piz2"}" = {
        hostname = "172.16.34.5";
        user = "nutanix";
      };
      "${rot13 "vsp-agak-abqr3"}" = {
        hostname = "172.16.34.6";
        user = "root";
      };
      "${rot13 "vsp-agak-piz3"}" = {
        hostname = "172.16.34.7";
        user = "nutanix";
      };
      "${rot13 "vsp-agak-abqr-fcner"}" = {
        hostname = "172.16.34.8";
        user = "root";
      };
      "${rot13 "vsp-agak-piz-fcner"}" = {
        hostname = "172.16.34.9";
        user = "nutanix";
      };
      "${rot13 "vsp-qaf"}" = {
        hostname = "10.1.1.10";
        user = rot13 "vsp-hfre";
      };
      "${rot13 "rqryv-qaf"}" = {
        hostname = "10.1.1.6";
        user = rot13 "vsp-hfre";
      };
      "${rot13 "srnc-grfgvat"}" = {
        hostname = "172.16.34.91";
        port = 10022;
        user = rot13 "vsp-hfre";
      };
    };
  };

  # KeePassXC
  systemd.user.services.keepassxc = {
    Unit = {
      Description = "KeePassXC password manager";
      Requires = [ "ssh-agent.service" "tray.target" ];
      After = [ "graphical-session-pre.target" "ssh-agent.service" "tray.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };

    Service = {
      ExecStart = "${pkgs.keepassxc}/bin/keepassxc %h/misc/all/db.kdbx";
      Restart = "on-failure";
      Environment = [
        "SSH_AUTH_SOCK=%t/ssh-agent"
        "PATH=/etc/profiles/per-user/%u/bin" # XXX Qt find plugins from PATH
      ];
    };
  };

  home.file.".config/keepassxc/keepassxc.ini".source = ./keepassxc.ini;

  #hyfetch
  xdg.configFile."hyfetch.json".text = builtins.toJSON {
    preset = "queer";
    mode = "rgb";
    light_dark = "dark";
    lightness = 0.5;
    color_align = {
      mode = "horizontal";
      custom_colors = [ ];
      fore_back = null;
    };
  };

  # GnuPG
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
    settings = {
      no-greeting = true;
      # use SHA-512 when signing a key
      #cert-digest-algo = "SHA512";
      # override recipient key cipher preferences
      # remove 3DES and prefer AES256
      #personal-cipher-preferences = "AES256 AES192 AES CAST5";
      # override recipient key digest preferences
      # remove SHA-1 and prefer SHA-512
      #personal-digest-preferences = "SHA512 SHA384 SHA256 SHA224";
      # remove SHA-1 and 3DES from cipher preferences of newly created key
      default-preference-list = "SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed";
      # reject SHA-1 signature
      weak-digest = "SHA1";
      # never allow use 3DES
      disable-cipher-algo = "3DES";
      # use AES256 when symmetric encryption
      #s2k-cipher-algo = "AES256";
      # use SHA-512 when symmetric encryption
      #s2k-digest-algo = "SHA512";
      # mangle password many times as possible when symmetric encryption
      s2k-count = "65011712";
      # both short and long key IDs are insecure
      keyid-format = "none";
      # use full fingerprint instead
      with-subkey-fingerprint = true;
    };
    mutableKeys = false;
    mutableTrust = false;
    publicKeys = [
      {
        source = ./my-pubkeys.gpg;
        trust = "ultimate";
      }
    ];
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "gnome3";
    enableScDaemon = false;
    defaultCacheTtl = 0;
    maxCacheTtl = 0;
  };

  home.enableDebugInfo = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Nemo
      "inode/directory" = "nemo.desktop";

      # Zathura
      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
      "application/postscript" = "org.pwmt.zathura-ps.desktop";
      "application/eps" = "org.pwmt.zathura-ps.desktop";
      "application/x-eps" = "org.pwmt.zathura-ps.desktop";
      "image/eps" = "org.pwmt.zathura-ps.desktop";
      "image/x-eps" = "org.pwmt.zathura-ps.desktop";

      # VLC
      "application/ogg" = "vlc.desktop";
      "application/x-ogg" = "vlc.desktop";
      "audio/ogg" = "vlc.desktop";
      "audio/vorbis" = "vlc.desktop";
      "audio/x-vorbis" = "vlc.desktop";
      "audio/x-vorbis+ogg" = "vlc.desktop";
      "video/ogg" = "vlc.desktop";
      "video/x-ogm" = "vlc.desktop";
      "video/x-ogm+ogg" = "vlc.desktop";
      "video/x-theora+ogg" = "vlc.desktop";
      "video/x-theora" = "vlc.desktop";
      "audio/x-speex" = "vlc.desktop";
      "audio/opus" = "vlc.desktop";
      "application/x-flac" = "vlc.desktop";
      "audio/flac" = "vlc.desktop";
      "audio/x-flac" = "vlc.desktop";
      "audio/x-ms-asf" = "vlc.desktop";
      "audio/x-ms-asx" = "vlc.desktop";
      "audio/x-ms-wax" = "vlc.desktop";
      "audio/x-ms-wma" = "vlc.desktop";
      "video/x-ms-asf" = "vlc.desktop";
      "video/x-ms-asf-plugin" = "vlc.desktop";
      "video/x-ms-asx" = "vlc.desktop";
      "video/x-ms-wm" = "vlc.desktop";
      "video/x-ms-wmv" = "vlc.desktop";
      "video/x-ms-wmx" = "vlc.desktop";
      "video/x-ms-wvx" = "vlc.desktop";
      "video/x-msvideo" = "vlc.desktop";
      "audio/x-pn-windows-acm" = "vlc.desktop";
      "video/divx" = "vlc.desktop";
      "video/msvideo" = "vlc.desktop";
      "video/vnd.divx" = "vlc.desktop";
      "video/avi" = "vlc.desktop";
      "video/x-avi" = "vlc.desktop";
      "application/vnd.rn-realmedia" = "vlc.desktop";
      "application/vnd.rn-realmedia-vbr" = "vlc.desktop";
      "audio/vnd.rn-realaudio" = "vlc.desktop";
      "audio/x-pn-realaudio" = "vlc.desktop";
      "audio/x-pn-realaudio-plugin" = "vlc.desktop";
      "audio/x-real-audio" = "vlc.desktop";
      "audio/x-realaudio" = "vlc.desktop";
      "video/vnd.rn-realvideo" = "vlc.desktop";
      "audio/mpeg" = "vlc.desktop";
      "audio/mpg" = "vlc.desktop";
      "audio/mp1" = "vlc.desktop";
      "audio/mp2" = "vlc.desktop";
      "audio/mp3" = "vlc.desktop";
      "audio/x-mp1" = "vlc.desktop";
      "audio/x-mp2" = "vlc.desktop";
      "audio/x-mp3" = "vlc.desktop";
      "audio/x-mpeg" = "vlc.desktop";
      "audio/x-mpg" = "vlc.desktop";
      "video/mp2t" = "vlc.desktop";
      "video/mpeg" = "vlc.desktop";
      "video/mpeg-system" = "vlc.desktop";
      "video/x-mpeg" = "vlc.desktop";
      "video/x-mpeg2" = "vlc.desktop";
      "video/x-mpeg-system" = "vlc.desktop";
      "application/mpeg4-iod" = "vlc.desktop";
      "application/mpeg4-muxcodetable" = "vlc.desktop";
      "application/x-extension-m4a" = "vlc.desktop";
      "application/x-extension-mp4" = "vlc.desktop";
      "audio/aac" = "vlc.desktop";
      "audio/m4a" = "vlc.desktop";
      "audio/mp4" = "vlc.desktop";
      "audio/x-m4a" = "vlc.desktop";
      "audio/x-aac" = "vlc.desktop";
      "video/mp4" = "vlc.desktop";
      "video/mp4v-es" = "vlc.desktop";
      "video/x-m4v" = "vlc.desktop";
      "application/x-quicktime-media-link" = "vlc.desktop";
      "application/x-quicktimeplayer" = "vlc.desktop";
      "video/quicktime" = "vlc.desktop";
      "application/x-matroska" = "vlc.desktop";
      "audio/x-matroska" = "vlc.desktop";
      "video/x-matroska" = "vlc.desktop";
      "video/webm" = "vlc.desktop";
      "audio/webm" = "vlc.desktop";
      "audio/3gpp" = "vlc.desktop";
      "audio/3gpp2" = "vlc.desktop";
      "audio/AMR" = "vlc.desktop";
      "audio/AMR-WB" = "vlc.desktop";
      "video/3gp" = "vlc.desktop";
      "video/3gpp" = "vlc.desktop";
      "video/3gpp2" = "vlc.desktop";
      "x-scheme-handler/mms" = "vlc.desktop";
      "x-scheme-handler/mmsh" = "vlc.desktop";
      "x-scheme-handler/rtsp" = "vlc.desktop";
      "x-scheme-handler/rtp" = "vlc.desktop";
      "x-scheme-handler/rtmp" = "vlc.desktop";
      "x-scheme-handler/icy" = "vlc.desktop";
      "x-scheme-handler/icyx" = "vlc.desktop";
      "application/x-cd-image" = "vlc.desktop";
      "x-content/video-vcd" = "vlc.desktop";
      "x-content/video-svcd" = "vlc.desktop";
      "x-content/video-dvd" = "vlc.desktop";
      "x-content/audio-cdda" = "vlc.desktop";
      "x-content/audio-player" = "vlc.desktop";
      "application/ram" = "vlc.desktop";
      "application/xspf+xml" = "vlc.desktop";
      "audio/mpegurl" = "vlc.desktop";
      "audio/x-mpegurl" = "vlc.desktop";
      "audio/scpls" = "vlc.desktop";
      "audio/x-scpls" = "vlc.desktop";
      "text/google-video-pointer" = "vlc.desktop";
      "text/x-google-video-pointer" = "vlc.desktop";
      "video/vnd.mpegurl" = "vlc.desktop";
      "application/vnd.apple.mpegurl" = "vlc.desktop";
      "application/vnd.ms-asf" = "vlc.desktop";
      "application/vnd.ms-wpl" = "vlc.desktop";
      "application/sdp" = "vlc.desktop";
      "audio/dv" = "vlc.desktop";
      "video/dv" = "vlc.desktop";
      "audio/x-aiff" = "vlc.desktop";
      "audio/x-pn-aiff" = "vlc.desktop";
      "video/x-anim" = "vlc.desktop";
      "video/x-nsv" = "vlc.desktop";
      "video/fli" = "vlc.desktop";
      "video/flv" = "vlc.desktop";
      "video/x-flc" = "vlc.desktop";
      "video/x-fli" = "vlc.desktop";
      "video/x-flv" = "vlc.desktop";
      "audio/wav" = "vlc.desktop";
      "audio/x-pn-au" = "vlc.desktop";
      "audio/x-pn-wav" = "vlc.desktop";
      "audio/x-wav" = "vlc.desktop";
      "audio/x-adpcm" = "vlc.desktop";
      "audio/ac3" = "vlc.desktop";
      "audio/eac3" = "vlc.desktop";
      "audio/vnd.dts" = "vlc.desktop";
      "audio/vnd.dts.hd" = "vlc.desktop";
      "audio/vnd.dolby.heaac.1" = "vlc.desktop";
      "audio/vnd.dolby.heaac.2" = "vlc.desktop";
      "audio/vnd.dolby.mlp" = "vlc.desktop";
      "audio/basic" = "vlc.desktop";
      "audio/midi" = "vlc.desktop";
      "audio/x-ape" = "vlc.desktop";
      "audio/x-gsm" = "vlc.desktop";
      "audio/x-musepack" = "vlc.desktop";
      "audio/x-tta" = "vlc.desktop";
      "audio/x-wavpack" = "vlc.desktop";
      "audio/x-shorten" = "vlc.desktop";
      "application/x-shockwave-flash" = "vlc.desktop";
      "application/x-flash-video" = "vlc.desktop";
      "misc/ultravox" = "vlc.desktop";
      "image/vnd.rn-realpix" = "vlc.desktop";
      "audio/x-it" = "vlc.desktop";
      "audio/x-mod" = "vlc.desktop";
      "audio/x-s3m" = "vlc.desktop";
      "audio/x-xm" = "vlc.desktop";
      "application/mxf" = "vlc.desktop";

      # imv
      "image/bmp" = "imv-folder.desktop";
      "image/gif" = "imv-folder.desktop";
      "image/jpeg" = "imv-folder.desktop";
      "image/jpg" = "imv-folder.desktop";
      "image/pjpeg" = "imv-folder.desktop";
      "image/png" = "imv-folder.desktop";
      "image/tiff" = "imv-folder.desktop";
      "image/x-bmp" = "imv-folder.desktop";
      "image/x-pcx" = "imv-folder.desktop";
      "image/x-png" = "imv-folder.desktop";
      "image/x-portable-anymap" = "imv-folder.desktop";
      "image/x-portable-bitmap" = "imv-folder.desktop";
      "image/x-portable-graymap" = "imv-folder.desktop";
      "image/x-portable-pixmap" = "imv-folder.desktop";
      "image/x-tga" = "imv-folder.desktop";
      "image/x-xbitmap" = "imv-folder.desktop";

      # thunderbird
      "x-scheme-handler/mailto" = "thunderbird.desktop";

      # inkscape
      "image/svg+xml" = "org.inkscape.Inkscape.desktop";
      "image/svg+xml-compressed" = "org.inkscape.Inkscape.desktop";
    };
  };

  home.packages = with pkgs; [
    binutils
    gdb
    strace
    ltrace
    wl-clipboard
    xdg-utils
    powertop
    borgbackup
    pulseaudio
    glib.bin #gsettings
    evtest
    libinput.bin #libinput
    libnotify #notify-send
    picocom
    binwalk
    hashcat
    libsecret # secret-tool
    zbar
    qrencode

    gnome.dconf-editor
    gnome.gnome-font-viewer
    freecad
    gimp
    gscan2pdf # scanning tool
    imv
    inkscape
    keepassxc
    lollypop
    wdisplays
    pavucontrol
    gnome.gnome-clocks
    shotwell
    thunderbird
    vlc
    wev
    gnome.gnome-power-manager
    networkmanagerapplet
    #wxmaxima
    libreoffice
    xorg.xlsclients
    cinnamon.nemo
    gnome.gnome-disk-utility
    gnome.file-roller
  ];
}
