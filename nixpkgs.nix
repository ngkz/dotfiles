# Nixpkgs config
{ inputs }:
let
  inherit (inputs) nixpkgs-unstable agenix devshell self;

  # make nixos-unstable packages accessible through pkgs.unstable.package
  overlay-unstable = final: prev: {
    unstable = import nixpkgs-unstable { inherit (prev) system; };
  };

  overlay-my-packages = final: prev: {
    my = self.packages.${prev.system};
  };
in
{
  overlays = [
    agenix.overlay # add agenix package
    devshell.overlay
    overlay-unstable
    overlay-my-packages
  ];
  config.allowUnfree = true;
}
