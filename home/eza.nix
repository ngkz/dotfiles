# eza: modern ls
{ ... }: {
  programs.eza.enable = true;
  home.shellAliases = {
    ls = "eza --icons --time-style=iso --git";
    l = "ls";
    ll = "ls -lgh";
    la = "ls -aa";
    lt = "ls -lgh --tree";
    lta = "lt -a";
    lla = "ll -aa";
  };
}
