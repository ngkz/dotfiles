# modern du
{ pkgs, ... }: {
  home.packages = with pkgs; [
    du-dust
  ];

  programs.zsh.shellAliases.du = "dust";
}
