{ ... }:
{
  tmpfs-as-home.persistentDirs = [
    ".local/share/direnv"
  ];

  # Prevent commiting credentials accidentally
  programs.git.ignores = [ ".envrc" ];

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };
}
