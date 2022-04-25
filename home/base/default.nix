{ pkgs, ... }: {
  imports = [
    ./zsh
  ];

  # enable ~/.config, ~/.cache and ~/.local/share management
  xdg.enable = true;

  home.tmpfs-as-home.persistentDirs = [
    ".local/share/nix" # nix repl history
  ];

  # FZF fuzzy finder
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
  };

  # bat: modern cat
  programs.bat = {
    enable = true;
    config.theme = "Monokai Extended";
  };

  # exa: modern ls
  programs.exa.enable = true;

  programs.jq.enable = true;

  home.packages = with pkgs; [
    # modern unix commands
    bpytop # top
    du-dust # modern du
    dogdns # dig
    fd # find
    httpie # modern curl
    hyperfine # benchmarking tool
    ncdu # du
    sd #modern sed
    procs # modern ps
    ripgrep # modern grep

    binutils
    gdb
    hddtemp
    inetutils
    inotify-tools
    iotop
    lm_sensors
    netcat-openbsd
    p7zip
    parted
    pigz
    python3
    s-tui
    smartmontools #smartctl
    tealdeer # C tldr client is broken
    termshark
    unrar
    unzipNLS
    usbutils #lsusb
    wget
    monolith # Save complete web pages as a single HTML file
  ];

  # neovim
  programs.neovim.enable = true;
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
