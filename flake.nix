# Warning: The whole directory of a flake is copied to the nix store when the flake is evaluated. So don't let secrets lie around in a flake. If you use git or mercurial, ignored files are not copied.
{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager/release-21.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, agenix, flake-utils, home-manager }:
    let
      lib = nixpkgs.lib.extend (final: prev: {
        my = import ./lib.nix { lib = final; };
      });

      inherit (lib.my) loadModuleDir;
      inherit (builtins) attrValues readDir;
      inherit (lib) mapAttrs;
    in {
      lib = lib.my;

      # Used with `nixos-rebuild --flake .#<hostname>`
      nixosConfigurations = mapAttrs (name: _: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # https://nixos.org/manual/nixos/stable/index.html#sec-configuration-syntax
          # https://nixos.org/manual/nixos/stable/index.html#sec-writing-modules
          {
            networking.hostName = name;
          }
          agenix.nixosModules.age
          home-manager.nixosModule
          (./hosts + "/${name}")
        ] ++ attrValues self.nixosModules;
        specialArgs = {
          inherit lib inputs;
        };
      }) (readDir ./hosts);

      nixosModules = loadModuleDir ./modules;
      homeManagerModules = loadModuleDir ./home;
    } //
      # devShell = { <system> = ./import shell.nix ... }
      flake-utils.lib.eachDefaultSystem
      (system:
        let
          cfg = (import ./nixpkgs.nix { inherit inputs; }) // { inherit system; };
          pkgs = import nixpkgs cfg;
        in
        {
          devShell = import ./shell.nix { inherit pkgs; };
        });
}

