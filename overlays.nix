# Nixpkgs config
{ self, nixpkgs-unstable, ... } @ inputs:
{
  # make nixos-unstable packages accessible through pkgs.unstable.package
  unstable = final: prev: {
    unstable = import nixpkgs-unstable { inherit (prev) system; };
  };

  packages = final: prev: {
    ngkz = self.packages.${prev.system} // (import ./packages/lib { pkgs = final; });
  };

  sway-im = final: prev: {
    sway-unwrapped = self.packages.${prev.system}.sway-im-unwrapped;
  };

  latest-fcitx5 = final: prev: {
    # build unstable fcitx5 with stable dependencies
    # you can't just "fcitx5 = prev.unstable.fcitx5" because it leads to loading
    # multiple versions of the same library into the process and causing a conflict.
    fcitx5 = prev.callPackage "${nixpkgs-unstable}/pkgs/tools/inputmethods/fcitx5" {
      cldr-annotations = prev.unstable.cldr-annotations;
    };
  };
}
