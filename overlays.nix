{ self, nixpkgs, nixpkgs-unstable, ... } @ inputs:
{
  packages = final: prev: {
    ngkz = (import ./packages { pkgs = final; inherit inputs; })
      // (import ./packages/lib { pkgs = final; });
  };

  sway-im = final: prev: {
    sway = prev.sway.override {
      sway-unwrapped = final.ngkz.sway-im-unwrapped;
    };
  };

  fcitx5 = final: prev: {
    fcitx5-with-addons = final.ngkz.fcitx5-with-addons;
  };

  # make nixos-unstable packages accessible through pkgs.unstable.package
  unstable = final: prev: {
    unstable = import nixpkgs-unstable { inherit (prev) system; };
  };
}
