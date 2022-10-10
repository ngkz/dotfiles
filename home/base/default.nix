{ pkgs, ... }: {
  imports = [
    ./zsh
    ./tealdeer.nix
  ];

  # enable ~/.config, ~/.cache and ~/.local/share management
  xdg.enable = true;

  home.tmpfs-as-home.persistentDirs = [
    ".local/share/nix" # nix repl history
    ".cache/nix-index"
    ".local/share/nvim"
    ".local/share/state" # less, etc
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
    btop # top
    du-dust # modern du
    dogdns # dig
    fd # find
    httpie # modern curl
    hyperfine # benchmarking tool
    ncdu # du
    sd #modern sed
    procs # modern ps
    ripgrep # modern grep
    choose # modern cut

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
    termshark
    usbutils #lsusb
    wget
    monolith # Save complete web pages as a single HTML file
    neofetch
    ngkz.hyfetch-unstable
    stress
    efibootmgr
    file
    python3Packages.yq
    openssl
    unixtools.xxd
    nix-index
    ddrescue
    socat
    sdparm
    hdparm
    ntfsprogs
    bc
    pciutils #lspci
    lshw
  ];

  # neovim
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      base16-vim
      indentLine
      nerdtree
      nerdtree-git-plugin
      vim-commentary
      vim-endwise
      vim-gitgutter
      vim-polyglot
      vim-repeat
      vim-rooter
      vim-rsi
      vim-table-mode
      (pkgs.vimUtils.buildVimPlugin {
        name = "flygrep-vim";
        src = pkgs.fetchFromGitHub {
          owner = "wsdjeg";
          repo = "FlyGrep.vim";
          rev = "7a74448ac7635f8650127fc43016d24bb448ab50";
          sha256 = "1dSVL027AHZaTmTZlVnJYkwB80VblwVDheo+4QDsO8E=";
        };
      })
      auto-pairs
      (pkgs.vimUtils.buildVimPlugin {
        name = "braceless-vim";
        src = pkgs.fetchFromGitHub {
          owner = "tweekmonster";
          repo = "braceless.vim";
          rev = "3928fe18fb7c8561beed6a945622fd985a8e638b";
          sha256 = "QqyWK76FPQdIRuYrAGjM01qlbNtQ5E5PRG6hw3dm1Io=";
        };
        dontBuild = true;
      })
      fzf-vim
      vim-surround
      fcitx-vim
    ];
    extraPackages = with pkgs; [
      fzf
      fd
      ripgrep
    ];
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = builtins.replaceStrings [ "@fcitx5-remote@" ] [ "${pkgs.fcitx5}/bin/fcitx5-remote" ]
      (builtins.readFile ./init.vim);
  };
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
  home.stateVersion = "22.05";
}
