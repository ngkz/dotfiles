{ inputs, lib, config, pkgs, ... }:
let
  inherit (lib.ngkz) rot13;
  canberra-gtk-play = "${pkgs.libcanberra-gtk3}/bin/canberra-gtk-play";
in
{
  imports = [
    inputs.self.homeManagerModules.theming
    ./direnv.nix
    ../im
    #./chromium.nix
    ./syncthing.nix
    ./librewolf
    ./wine.nix
    ./doom-emacs
    ../hyfetch.nix
    # ../gtkcord4.nix
    ../telegram.nix
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
  tmpfs-as-home.persistentDirs = [
    ".local/share/wireplumber"
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
    # tauon
    ".local/share/TauonMusicBox"
    # libreoffice
    ".config/libreoffice"
    # transmission
    ".config/transmission"
    # FreeCAD
    ".FreeCAD"
    ".config/FreeCAD"
    # shotcut
    ".config/Meltytech"
    ".local/share/Meltytech/Shotcut"
    # electrum
    ".electrum"
  ];

  # shotwell
  xdg.dataFile."shotwell".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/misc/shotwell";

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Monospace:size=9";
        dpi-aware = "no";
      };

      bell = {
        urgent = "yes";
        command = "${canberra-gtk-play} -i bell";
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
        hostname = "peregrine.home.arpa";
        user = "user";
        port = 35822;
      };
      rednecked = {
        hostname = "f2l.cc";
        user = "user";
        port = 443;
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
  programs.git = {
    signing.key = "BC6DCFE03513A9FA4F55D70206B8106665DD36F3";
    extraConfig.tag.gpgSign = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "gnome3";
    enableScDaemon = false;
    defaultCacheTtl = 0;
    maxCacheTtl = 0;
  };

  home.enableDebugInfo = true;

  # patch neovim desktop entry
  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    exec = "${pkgs.foot}/bin/foot -- nvim";
    terminal = false;
    icon = "nvim";
    startupNotify = false;
    mimeType = [
      "text/english"
      "text/plain"
      "text/x-makefile"
      "text/x-c++hdr"
      "text/x-c++src"
      "text/x-chdr"
      "text/x-csrc"
      "text/x-java"
      "text/x-moc"
      "text/x-pascal"
      "text/x-tcl"
      "text/x-tex"
      "application/x-shellscript"
      "text/x-c"
      "text/x-c++"
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Nemo
      "inode/directory" = "nemo.desktop";

      # Evince
      "application/vnd.comicbook-rar" = "org.gnome.Evince.desktop";
      "application/vnd.comicbook+zip" = "org.gnome.Evince.desktop";
      "application/x-cb7" = "org.gnome.Evince.desktop";
      "application/x-cbr" = "org.gnome.Evince.desktop";
      "application/x-cbt" = "org.gnome.Evince.desktop";
      "application/x-cbz" = "org.gnome.Evince.desktop";
      "application/x-ext-cb7" = "org.gnome.Evince.desktop";
      "application/x-ext-cbr" = "org.gnome.Evince.desktop";
      "application/x-ext-cbt" = "org.gnome.Evince.desktop";
      "application/x-ext-cbz" = "org.gnome.Evince.desktop";
      "application/x-ext-djv" = "org.gnome.Evince.desktop";
      "application/x-ext-djvu" = "org.gnome.Evince.desktop";
      "image/vnd.djvu" = "org.gnome.Evince.desktop";
      "application/x-bzdvi" = "org.gnome.Evince.desktop";
      "application/x-dvi" = "org.gnome.Evince.desktop";
      "application/x-ext-dvi" = "org.gnome.Evince.desktop";
      "application/x-gzdvi" = "org.gnome.Evince.desktop";
      "application/pdf" = "org.gnome.Evince.desktop";
      "application/x-bzpdf" = "org.gnome.Evince.desktop";
      "application/x-ext-pdf" = "org.gnome.Evince.desktop";
      "application/x-gzpdf" = "org.gnome.Evince.desktop";
      "application/x-xzpdf" = "org.gnome.Evince.desktop";
      "application/postscript" = "org.gnome.Evince.desktop";
      "application/x-bzpostscript" = "org.gnome.Evince.desktop";
      "application/x-gzpostscript" = "org.gnome.Evince.desktop";
      "application/x-ext-eps" = "org.gnome.Evince.desktop";
      "application/x-ext-ps" = "org.gnome.Evince.desktop";
      "image/x-bzeps" = "org.gnome.Evince.desktop";
      "image/x-eps" = "org.gnome.Evince.desktop";
      "image/x-gzeps" = "org.gnome.Evince.desktop";
      "application/oxps" = "org.gnome.Evince.desktop";
      "application/vnd.ms-xpsdocument" = "org.gnome.Evince.desktop";

      # mpv
      "application/ogg" = "mpv.desktop";
      "application/x-ogg" = "mpv.desktop";
      "application/mxf" = "mpv.desktop";
      "application/sdp" = "mpv.desktop";
      "application/smil" = "mpv.desktop";
      "application/x-smil" = "mpv.desktop";
      "application/streamingmedia" = "mpv.desktop";
      "application/x-streamingmedia" = "mpv.desktop";
      "application/vnd.rn-realmedia" = "mpv.desktop";
      "application/vnd.rn-realmedia-vbr" = "mpv.desktop";
      "audio/aac" = "mpv.desktop";
      "audio/x-aac" = "mpv.desktop";
      "audio/vnd.dolby.heaac.1" = "mpv.desktop";
      "audio/vnd.dolby.heaac.2" = "mpv.desktop";
      "audio/aiff" = "mpv.desktop";
      "audio/x-aiff" = "mpv.desktop";
      "audio/m4a" = "mpv.desktop";
      "audio/x-m4a" = "mpv.desktop";
      "application/x-extension-m4a" = "mpv.desktop";
      "audio/mp1" = "mpv.desktop";
      "audio/x-mp1" = "mpv.desktop";
      "audio/mp2" = "mpv.desktop";
      "audio/x-mp2" = "mpv.desktop";
      "audio/mp3" = "mpv.desktop";
      "audio/x-mp3" = "mpv.desktop";
      "audio/mpeg" = "mpv.desktop";
      "audio/mpeg2" = "mpv.desktop";
      "audio/mpeg3" = "mpv.desktop";
      "audio/mpegurl" = "mpv.desktop";
      "audio/x-mpegurl" = "mpv.desktop";
      "audio/mpg" = "mpv.desktop";
      "audio/x-mpg" = "mpv.desktop";
      "audio/rn-mpeg" = "mpv.desktop";
      "audio/musepack" = "mpv.desktop";
      "audio/x-musepack" = "mpv.desktop";
      "audio/ogg" = "mpv.desktop";
      "audio/scpls" = "mpv.desktop";
      "audio/x-scpls" = "mpv.desktop";
      "audio/vnd.rn-realaudio" = "mpv.desktop";
      "audio/wav" = "mpv.desktop";
      "audio/x-pn-wav" = "mpv.desktop";
      "audio/x-pn-windows-pcm" = "mpv.desktop";
      "audio/x-realaudio" = "mpv.desktop";
      "audio/x-pn-realaudio" = "mpv.desktop";
      "audio/x-ms-wma" = "mpv.desktop";
      "audio/x-pls" = "mpv.desktop";
      "audio/x-wav" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "video/x-mpeg2" = "mpv.desktop";
      "video/x-mpeg3" = "mpv.desktop";
      "video/mp4v-es" = "mpv.desktop";
      "video/x-m4v" = "mpv.desktop";
      "video/mp4" = "mpv.desktop";
      "application/x-extension-mp4" = "mpv.desktop";
      "video/divx" = "mpv.desktop";
      "video/vnd.divx" = "mpv.desktop";
      "video/msvideo" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/ogg" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/vnd.rn-realvideo" = "mpv.desktop";
      "video/x-ms-afs" = "mpv.desktop";
      "video/x-ms-asf" = "mpv.desktop";
      "audio/x-ms-asf" = "mpv.desktop";
      "application/vnd.ms-asf" = "mpv.desktop";
      "video/x-ms-wmv" = "mpv.desktop";
      "video/x-ms-wmx" = "mpv.desktop";
      "video/x-ms-wvxvideo" = "mpv.desktop";
      "video/x-avi" = "mpv.desktop";
      "video/avi" = "mpv.desktop";
      "video/x-flic" = "mpv.desktop";
      "video/fli" = "mpv.desktop";
      "video/x-flc" = "mpv.desktop";
      "video/flv" = "mpv.desktop";
      "video/x-flv" = "mpv.desktop";
      "video/x-theora" = "mpv.desktop";
      "video/x-theora+ogg" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/mkv" = "mpv.desktop";
      "audio/x-matroska" = "mpv.desktop";
      "application/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "audio/webm" = "mpv.desktop";
      "audio/vorbis" = "mpv.desktop";
      "audio/x-vorbis" = "mpv.desktop";
      "audio/x-vorbis+ogg" = "mpv.desktop";
      "video/x-ogm" = "mpv.desktop";
      "video/x-ogm+ogg" = "mpv.desktop";
      "application/x-ogm" = "mpv.desktop";
      "application/x-ogm-audio" = "mpv.desktop";
      "application/x-ogm-video" = "mpv.desktop";
      "application/x-shorten" = "mpv.desktop";
      "audio/x-shorten" = "mpv.desktop";
      "audio/x-ape" = "mpv.desktop";
      "audio/x-wavpack" = "mpv.desktop";
      "audio/x-tta" = "mpv.desktop";
      "audio/AMR" = "mpv.desktop";
      "audio/ac3" = "mpv.desktop";
      "audio/eac3" = "mpv.desktop";
      "audio/amr-wb" = "mpv.desktop";
      "video/mp2t" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
      "audio/mp4" = "mpv.desktop";
      "application/x-mpegurl" = "mpv.desktop";
      "video/vnd.mpegurl" = "mpv.desktop";
      "application/vnd.apple.mpegurl" = "mpv.desktop";
      "audio/x-pn-au" = "mpv.desktop";
      "video/3gp" = "mpv.desktop";
      "video/3gpp" = "mpv.desktop";
      "video/3gpp2" = "mpv.desktop";
      "audio/3gpp" = "mpv.desktop";
      "audio/3gpp2" = "mpv.desktop";
      "video/dv" = "mpv.desktop";
      "audio/dv" = "mpv.desktop";
      "audio/opus" = "mpv.desktop";
      "audio/vnd.dts" = "mpv.desktop";
      "audio/vnd.dts.hd" = "mpv.desktop";
      "audio/x-adpcm" = "mpv.desktop";
      "application/x-cue" = "mpv.desktop";
      "audio/m3u" = "mpv.desktop";

      # imv
      "image/bmp" = "imv-dir.desktop";
      "image/gif" = "imv-dir.desktop";
      "image/jpeg" = "imv-dir.desktop";
      "image/jpg" = "imv-dir.desktop";
      "image/pjpeg" = "imv-dir.desktop";
      "image/png" = "imv-dir.desktop";
      "image/tiff" = "imv-dir.desktop";
      "image/x-bmp" = "imv-dir.desktop";
      "image/x-pcx" = "imv-dir.desktop";
      "image/x-png" = "imv-dir.desktop";
      "image/x-portable-anymap" = "imv-dir.desktop";
      "image/x-portable-bitmap" = "imv-dir.desktop";
      "image/x-portable-graymap" = "imv-dir.desktop";
      "image/x-portable-pixmap" = "imv-dir.desktop";
      "image/x-tga" = "imv-dir.desktop";
      "image/x-xbitmap" = "imv-dir.desktop";

      # thunderbird
      "x-scheme-handler/mailto" = "thunderbird.desktop";

      # inkscape
      "image/svg+xml" = "org.inkscape.Inkscape.desktop";
      "image/svg+xml-compressed" = "org.inkscape.Inkscape.desktop";
      "application/vnd.corel-draw" = "org.inkscape.Inkscape.desktop";
      "application/illustrator" = "org.inkscape.Inkscape.desktop";
      "image/cgm" = "org.inkscape.Inkscape.desktop";
      "image/x-wmf" = "org.inkscape.Inkscape.desktop";
      "application/x-xccx" = "org.inkscape.Inkscape.desktop";
      "application/x-xcgm" = "org.inkscape.Inkscape.desktop";
      "application/x-xcdt" = "org.inkscape.Inkscape.desktop";
      "application/x-xsk1" = "org.inkscape.Inkscape.desktop";
      "application/x-xcmx" = "org.inkscape.Inkscape.desktop";
      "image/x-xcdr" = "org.inkscape.Inkscape.desktop";
      "application/visio" = "org.inkscape.Inkscape.desktop";
      "application/x-visio" = "org.inkscape.Inkscape.desktop";
      "application/visio.drawing" = "org.inkscape.Inkscape.desktop";
      "application/vsd" = "org.inkscape.Inkscape.desktop";
      "application/x-vsd" = "org.inkscape.Inkscape.desktop";
      "image/x-vsd" = "org.inkscape.Inkscape.desktop";

      # neovim
      "text/english" = "nvim.desktop";
      "text/plain" = "nvim.desktop";
      "text/x-makefile" = "nvim.desktop";
      "text/x-c++hdr" = "nvim.desktop";
      "text/x-c++src" = "nvim.desktop";
      "text/x-chdr" = "nvim.desktop";
      "text/x-csrc" = "nvim.desktop";
      "text/x-java" = "nvim.desktop";
      "text/x-moc" = "nvim.desktop";
      "text/x-pascal" = "nvim.desktop";
      "text/x-tcl" = "nvim.desktop";
      "text/x-tex" = "nvim.desktop";
      "application/x-shellscript" = "nvim.desktop";
      "text/x-c" = "nvim.desktop";
      "text/x-c++" = "nvim.desktop";

      # wine
      "application/x-ms-dos-executable" = "wine.desktop";
    };
  };

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
    };
  };

  dconf.settings = {
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };

    # nemo
    "org/cinnamon/desktop/applications/terminal" = {
      exec = "foot";
      exec-args = "--";
    };

    "org/nemo/list-view" = {
      default-column-order = [ "name" "size" "type" "date_modified" "octal_permissions" "mime_type" "date_accessed" "group" "permissions" "date_created_with_time" "date_created" "where" "owner" "detailed_type" "date_modified_with_time" ];
      default-visible-columns = [ "name" "size" "type" "date_modified" "permissions" ];
    };

    "org/nemo/preferences" = {
      date-format = "iso";
      quick-renames-with-pause-in-between = true;
      show-advanced-permissions = true;
      thumbnail-limit = lib.hm.gvariant.mkUint64 1073741824;
    };

    "org/nemo/preferences/menu-config" = {
      background-menu-open-as-root = false;
      selection-menu-open-as-root = false;
    };

    "org/nemo/window-state" = {
      sidebar-bookmark-breakpoint = 8;
    };
  };

  home.packages = with pkgs; [
    binutils
    gdb
    gcc
    strace
    ltrace
    wl-clipboard
    xdg-utils
    powertop
    pulseaudio
    glib.bin #gsettings
    evtest
    libinput.bin #libinput
    libnotify #notify-send
    picocom
    hashcat
    libsecret # secret-tool
    zbar
    qrencode
    yt-dlp
    mp3gain
    aacgain
    ffmpeg
    manix # nix documentation searcher
    psmisc
    hugo
    sqlite
    exiftool
    # bsdgames # conflicts with mono
    geteltorito
    sbsigntool
    tpm2-tools
    efitools
    v4l-utils
    gphoto2
    ngkz.scripts
    mprime
    dislocker
    ansible
    jpegoptim
    optipng
    imagemagick

    gnome.dconf-editor
    gnome.gnome-font-viewer
    ngkz.freecad-realthunder
    gimp
    gscan2pdf # scanning tool
    imv
    inkscape
    keepassxc
    tauon
    wdisplays
    pavucontrol
    gnome.gnome-clocks
    shotwell
    thunderbird
    wev
    gnome.gnome-power-manager
    networkmanagerapplet
    #wxmaxima
    libreoffice
    xorg.xlsclients
    cinnamon.nemo
    ffmpegthumbnailer #video thumbnailer
    gnome.totem #audio/video thumbnailer
    gnome.gnome-disk-utility
    gnome.file-roller
    gnome.evince #pdf viewer/thumbnailer
    transmission-gtk
    filezilla
    shotcut
    vlc
    wireshark
    hexchat
    electrum
    tenacity
  ];
}
