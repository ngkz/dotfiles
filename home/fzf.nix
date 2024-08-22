# FZF fuzzy finder
{ pkgs, ... }: {
  programs.fzf = {
    enable = true;
    defaultCommand = "${pkgs.fd}/bin/fd --type f --hidden --exclude .git";
    # Ctrl+T: find and insert path
    # Alt+C: find and chdir
    # Ctrl+R: search history
    enableZshIntegration = true;
  };
}
