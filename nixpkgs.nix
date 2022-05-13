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

  overlay-sway-im = final: prev: {
    sway-unwrapped = prev.my.sway-im-unwrapped;
  };
in
{
  overlays = [
    agenix.overlay # add agenix package
    devshell.overlay
    overlay-unstable
    overlay-my-packages
    overlay-sway-im
  ];
  config.allowUnfree = true;
}
