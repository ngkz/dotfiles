{ pkgs, ... }: {
  imports = [
    ../tmpfs-as-home.nix
    ./zsh
    ./tealdeer.nix
    ../neovim
  ];

  xdg.enable = true;

  tmpfs-as-home.persistentDirs = [
    ".local/share/nix" # nix repl history
    ".cache/nix-index"
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

  # eza: modern ls
  programs.eza.enable = true;

  programs.jq.enable = true;

  programs.btop = {
    # modern top command
    enable = true;
    settings = {
      disks_filter = "exclude=/var/persist /var/snapshots /var/swap /var/log";
    };
  };

  # automatially trigger X-Restart-Triggers
  systemd.user.startServices = true;
}
