{ pkgs }:
let
  nodePackages = import ./nodePackages {
    inherit pkgs;
    inherit (pkgs) system nodejs;
  };
in
{
  sway-systemd = pkgs.callPackage ./sway-systemd { };
  sway-im-unwrapped = pkgs.callPackage ./sway-im-unwrapped { };
  fcitx5-mozc-ut = pkgs.callPackage ./fcitx5-mozc-ut.nix { };
  intel-undervolt = pkgs.callPackage ./intel-undervolt.nix { };
  sarasa-term-j-nerd-font = pkgs.callPackage ./sarasa-term-j-nerd-font.nix { };
  blobmoji-fontconfig = pkgs.callPackage ./blobmoji-fontconfig.nix { };
} // nodePackages
