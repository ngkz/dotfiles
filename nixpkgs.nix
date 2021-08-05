# Nixpkgs config
{ inputs }:
let
  inherit (inputs) nixpkgs-unstable agenix;

  # make nixos-unstable packages accessible through pkgs.unstable.package
  overlay-unstable = final: prev: {
    unstable = import nixpkgs-unstable { inherit (prev) system; };
  };
in {
  overlays = [
    agenix.overlay # add agenix package
    overlay-unstable
  ];
  config.allowUnfree = true;
}
