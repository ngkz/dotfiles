# Warning: The whole directory of a flake is copied to the nix store when the flake is evaluated. So don't let secrets lie around in a flake. If you use git or mercurial, ignored files are not copied.
{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    #XXX don't forget to update HM when NixOS upgrade!
    home-manager.url = "github:nix-community/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, flake-utils, ... }: {
    # Used with `nixos-rebuild --flake .#<hostname>`
    nixosConfigurations = {
      stagingvm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/stagingvm ];
        specialArgs = { inherit inputs; };
      };
      peregrine = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/peregrine ];
        specialArgs = { inherit inputs; };
      };
    };

    nixosModules = import ./modules;
    homeManagerModules = import ./home;
  } // flake-utils.lib.eachDefaultSystem (system: (
    let
      cfg = (import ./nixpkgs.nix { inherit inputs; }) // { inherit system; };
      pkgs = import nixpkgs cfg;
    in
    {
      # devShell.<system> = pkgs.devshell.mkShell ...;
      devShell =
        pkgs.devshell.mkShell {
          imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
        };

      # packages.<system> = { <pkgname> = <derivation>, ... };
      packages = {
        sway-systemd = pkgs.callPackage ./packages/sway-systemd { };
        sway-im-unwrapped = pkgs.callPackage ./packages/sway-im-unwrapped { };
        fcitx5-mozc-ut = pkgs.callPackage ./packages/fcitx5-mozc-ut.nix { };
        intel-undervolt = pkgs.callPackage ./packages/intel-undervolt.nix { };
        plemoljp-nf = pkgs.callPackage ./packages/plemoljp-nf.nix { };
      };
    }
  ));
}

