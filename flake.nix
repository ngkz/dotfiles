# Warning: The whole directory of a flake is copied to the nix store when the flake is evaluated. So don't let secrets lie around in a flake. If you use git or mercurial, ignored files are not copied.
{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    #XXX don't forget to update HM when NixOS upgrade!
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, flake-utils, ... }:
    let
      lib = nixpkgs.lib.extend (final: prev: {
        ngkz = import ./lib.nix { lib = prev; };
      });
    in
    {
      # Used with `nixos-rebuild --flake .#<hostname>`
      nixosConfigurations = {
        stagingvm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/stagingvm ];
          specialArgs = { inherit inputs lib; };
        };
        peregrine = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/peregrine ];
          specialArgs = { inherit inputs lib; };
        };
      };

      nixosModules = import ./modules;
      homeManagerModules = import ./home;
      overlays = import ./overlays.nix inputs;
      overlay = self.overlays.packages;
      lib = lib.ngkz;
    } // flake-utils.lib.eachDefaultSystem (system: (
      let
        cfg = (import ./nixpkgs.nix inputs) // { inherit system; };
        pkgs = import nixpkgs cfg;
      in
      {
        # devShell.<system> = pkgs.devshell.mkShell ...;
        devShell =
          pkgs.devshell.mkShell {
            imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
          };

        # packages.<system> = { <pkgname> = <derivation>, ... };
        packages = import ./packages { inherit pkgs; inherit inputs; };
      }
    ));
}

