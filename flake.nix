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

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, agenix, flake-utils, home-manager }: {
    # Used with `nixos-rebuild --flake .#<hostname>`
    nixosConfigurations =  {
      stagingvm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/stagingvm ];
        specialArgs = { inherit inputs; };
      };
    };

    nixosModules = import ./modules;
    homeManagerModules = import ./home;
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

