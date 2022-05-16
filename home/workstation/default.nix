{ pkgs, ... }:
{
  imports = [
    ./direnv.nix
    ./fcitx5.nix
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

  #TODO
  programs.firefox.enable = true;
  #programs.chromium = {
  #  enable = true;
  #  package = pkgs.ungoogled-chromium;
  #};

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Sarasa Term J:size=8";
        #font = "Symbols Nerd Font:style=2048-em:size=9";
        #notify = "sh -c 'notify-send -a foot -i foot \"$1\" \"$2\"; paplay ~/.local/share/sounds/__custom/bell-terminal.ogg' _ \${title} \${body}";
      };

      bell = {
        notify = "yes";
      };

      scrollback = {
        lines = 65536;
      };

      colors = {
        # Base16 Tomorrow Night
        # Author: Chris Kempson (http://chriskempson.com)
        foreground = "c5c8c6";
        background = "1d1f21";
        alpha = 0.8;

        # 16 color space
        # Black, Gray, Silver, White
        regular0 = "1d1f21";
        bright0 = "969896";
        regular7 = "c5c8c6";
        bright7 = "ffffff";

        # Red
        regular1 = "cc6666";
        bright1 = "cc6666";

        # Green
        regular2 = "b5bd68";
        bright2 = "b5bd68";

        # Yellow
        regular3 = "f0c674";
        bright3 = "f0c674";

        # Blue
        regular4 = "81a2be";
        bright4 = "81a2be";

        # Purple
        regular5 = "b294bb";
        bright5 = "b294bb";

        # Teal
        regular6 = "8abeb7";
        bright6 = "8abeb7";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };
  };

  programs.zathura.enable = true; #PDF viewer

  home.packages = with pkgs; [
    wl-clipboard
    xdg-utils
    powertop
    borgbackup
    pulseaudio

    gnome.dconf-editor
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
  ];
}
