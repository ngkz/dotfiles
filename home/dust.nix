# modern du
{ pkgs, ... }: {
  home.packages = with pkgs; [
    du-dust
  ];
  home.shellAliases.du = "dust";
}
