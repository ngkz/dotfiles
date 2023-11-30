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

  sslh = final: prev: {
    sslh = final.ngkz.sslh-select.override {
      sslh = prev.sslh;
    };
  };

  #XXX 22.05 apparmor-utils package is broken. use stable package after NixOS 22.11 upgrade
  apparmor = final: prev: {
    inherit (final.ngkz) apparmor-utils;
  };

  # make nixos-unstable packages accessible through pkgs.unstable.package
  unstable = final: prev: {
    unstable = import nixpkgs-unstable { inherit (prev) system; };
  };
}
