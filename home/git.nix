{ config, lib, ... }: {
  programs.git = {
    enable = true;
    delta.enable = true;
    userName = "Kazutoshi Noguchi";
    userEmail = config.personal-email;
    extraConfig = {
      init.defaultBranch = "main";
      diff.tool = "nvimdiff";
      merge.tool = "nvimdiff";
    };
  };
  # See also: gnupg.nix
}
