# Warning: The whole directory of a flake is copied to the nix store when the flake is evaluated. So don't let secrets lie around in a flake. If you use git or mercurial, ignored files are not copied.
{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs-small.url = "nixpkgs/nixos-24.05-small";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    #TODO don't forget to update HM and badge when NixOS upgrade!
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-small, flake-utils, home-manager, ... }:
    let
      lib = nixpkgs.lib.extend (final: prev: {
        ngkz = import ./lib.nix { lib = prev; };
      });
    in
    {
      # Used with `nixos-rebuild --flake .#<hostname>`
      nixosConfigurations = {
        peregrine = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/peregrine ];
          specialArgs = { inherit inputs lib; };
        };
        rednecked = nixpkgs-small.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/rednecked ];
          specialArgs = { inherit inputs lib; };
        };
      };

      homeConfigurations = {
        kali = home-manager.lib.homeManagerConfiguration (
          let
            cfg = (import ./nixpkgs.nix inputs) // { system = "x86_64-linux"; };
          in
          {
            pkgs = import nixpkgs cfg;
            modules = [ ./hosts/kali ];
            extraSpecialArgs = {
              inherit inputs;
              lib = lib.extend (_: _: home-manager.lib);
            };
          }
        );
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
