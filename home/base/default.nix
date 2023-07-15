{ inputs, pkgs, ... }: {
  imports = with inputs.self.homeManagerModules; [
    core
    ./zsh
    ./tealdeer.nix
    neovim
  ];

  home.tmpfs-as-home.persistentDirs = [
    ".local/share/nix" # nix repl history
    ".cache/nix-index"
    ".local/state/home-manager"
    ".local/share/wireplumber"
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
}
