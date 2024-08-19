{ lib, ... }: {
  programs.git = {
    enable = true;
    delta.enable = true;
    userName = "Kazutoshi Noguchi";
    userEmail = lib.ngkz.rot13 "xa@s2y.pp";
    extraConfig = {
      init.defaultBranch = "main";
      diff.tool = "nvimdiff";
      merge.tool = "nvimdiff";
    };
  };
  # See also: gnupg.nix
}
