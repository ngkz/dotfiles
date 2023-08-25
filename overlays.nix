{ self, nixpkgs, ... } @ inputs:
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

  sslh = final: prev: {
    sslh = final.ngkz.sslh-select.override {
      sslh = prev.sslh;
    };
  };
}
