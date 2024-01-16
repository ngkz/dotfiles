{ lib, ... }: {
  programs.git = {
    enable = true;
    delta.enable = true;
    userName = "Kazutoshi Noguchi";
    userEmail = lib.ngkz.rot13 "abthpuv.xnmhgbfv+Nm0Twsg4@tznvy.pbz";
    signing.key = "BC6DCFE03513A9FA4F55D70206B8106665DD36F3";
    extraConfig = {
      init.defaultBranch = "main";
      diff.tool = "nvimdiff";
      merge.tool = "nvimdiff";
      tag.gpgSign = true;
    };
  };
}
