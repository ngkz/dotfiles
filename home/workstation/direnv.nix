{ lib, config, ... }:
let
  inherit (lib) mkIf;
in {
  config = mkIf config.f2l.workstation {
    f2l.home.persist.directories = [
      ".local/share/direnv"
    ];

    # Prevent commiting credentials accidentally
    programs.git.ignores = [ ".envrc" ];

    programs.direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
        enableFlakes = true;
      };
    };
  };
}
