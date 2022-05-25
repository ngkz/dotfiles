# Nixpkgs config
{ inputs }:
let
  inherit (inputs) nixpkgs-unstable agenix devshell self;

  # make nixos-unstable packages accessible through pkgs.unstable.package
  overlay-unstable = final: prev: {
    unstable = import nixpkgs-unstable { inherit (prev) system; };
  };

  overlay-my-packages = final: prev: {
    my = self.packages.${prev.system} // (import ./packages/lib { pkgs = final; });
  };

  overlay-sway-im = final: prev: {
    sway-unwrapped = prev.my.sway-im-unwrapped;
  };

  overlay-latest-fcitx5 = final: prev: {
    # build unstable fcitx5 with stable dependencies
    # you can't just "fcitx5 = prev.unstable.fcitx5" because it leads to loading
    # multiple versions of the same library into the process and causing a conflict.
    fcitx5 = prev.callPackage "${nixpkgs-unstable}/pkgs/tools/inputmethods/fcitx5" {
      cldr-annotations = prev.unstable.cldr-annotations;
    };
  };
in
{
  overlays = [
    agenix.overlay # add agenix package
    devshell.overlay
    overlay-unstable
    overlay-my-packages
    overlay-sway-im
    overlay-latest-fcitx5
  ];
  config.allowUnfree = true;
}
