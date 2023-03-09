{ inputs, pkgs, ... }: {
  imports = [
    inputs.self.homeManagerModules.core
    ./zsh
    ./tealdeer.nix
  ];

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

  programs.btop = {
    # modern top command
    enable = true;
    settings = {
      disks_filter = "exclude=/var/persist /var/snapshots /var/swap /var/log";
    };
  };

  home.packages = with pkgs; [
    # modern unix commands
    du-dust # modern du
    doggo #dig
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
    hyfetch
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
    sysfsutils #systool
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
      bclose-vim
      (pkgs.vimUtils.buildVimPlugin {
        name = "vim-dis";
        src = ./vim-dis;
        dontBuild = true;
      })
    ];
    extraPackages = with pkgs; [
      fzf
      fd
      ripgrep
    ];
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = builtins.readFile ./init.vim;
  };
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
