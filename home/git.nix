{ config, ... }: {
  programs.git = {
    enable = true;
    delta.enable = true;
    userName = "Kazutoshi Noguchi";
    userEmail = config.personalEmail;
    extraConfig = {
      init.defaultBranch = "main";
      diff.tool = "nvimdiff";
      merge.tool = "nvimdiff";
    };
  };
  # See also: gpg.nix
}
