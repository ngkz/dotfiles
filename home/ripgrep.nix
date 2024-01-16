# rg: modern and fast grep
{ pkgs, ... }: {
  home.packages = with pkgs; [ ripgrep ];
  home.shellAliases.rg = "rg -S";
}
