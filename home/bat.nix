# bat: modern cat
{ ... }: {
  programs.bat = {
    enable = true;
    config.theme = "Monokai Extended";
  };
  home.shellAliases.cat = "bat";
}
