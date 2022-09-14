{ pkgs, ... }:
let
  iniFormat = pkgs.formats.ini { };
  paplay = "${pkgs.pulseaudio}/bin/paplay";
in
{
  imports = [
    ./direnv.nix
    ./fcitx5.nix
    ./ungoogled-chromium.nix
  ];

  # XDG user dirs
  xdg.userDirs = {
    enable = true;
    desktop = "$HOME";
    #desktop = "$HOME/desktop";
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
    #"desktop"
  ];

  # Git
  programs.git = {
    enable = true;
    delta.enable = true;
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Monospace:size=9";
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
  programs.ssh.enable = true;
  systemd.user.services.ssh-agent = {
    Unit = {
      Description = "OpenSSH authentication agent";
    };

    Install = { WantedBy = [ "default.target" ]; };

    Service = {
      ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent.sock";
      Restart = "on-failure";
    };
  };
  systemd.user.sessionVariables.SSH_AUTH_SOCK = "\${SSH_AUTH_SOCK:-$XDG_RUNTIME_DIR/ssh-agent.sock}";
  home.sessionVariables.SSH_AUTH_SOCK = "\${SSH_AUTH_SOCK:-$XDG_RUNTIME_DIR/ssh-agent.sock}";

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
      ExecStart = "${pkgs.keepassxc}/bin/keepassxc";
      Restart = "on-failure";
    };
  };

  home.file.".config/keepassxc/keepassxc.ini".source = ./keepassxc.ini;

  home.packages = with pkgs; [
    wl-clipboard
    xdg-utils
    powertop
    borgbackup
    pulseaudio
    glib.bin #gsettings
    evtest
    libinput.bin #libinput
    libnotify #notify-send

    gnome.dconf-editor
    gnome.gnome-font-viewer
    freecad
    gimp
    gscan2pdf # scanning tool
    imv
    keepassxc
    lollypop
    wdisplays
    pcmanfm
    pavucontrol
    gnome.gnome-clocks
    shotwell
    thunderbird
    vlc
    wev
    gnome.gnome-power-manager
    networkmanagerapplet
  ];
}
