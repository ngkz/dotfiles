# Warning: The whole directory of a flake is copied to the nix store when the flake is evaluated. So don't let secrets lie around in a flake. If you use git or mercurial, ignored files are not copied.
{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    # TODO use upstream agenix after https://github.com/ryantm/agenix/pull/49 merge
    agenix.url = "github:ngkz/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager/release-21.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, agenix, flake-utils, home-manager }:
    let
      # make nixos-unstable packages accessible through pkgs.unstable.package
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable { inherit (prev) system; };
      };

      overlays = [
        agenix.overlay # add agenix package
        overlay-unstable
      ];
    in {
      # Used with `nixos-rebuild --flake .#<hostname>`
      nixosConfigurations = {
        stagingvm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # https://nixos.org/manual/nixos/stable/index.html#sec-configuration-syntax
            # https://nixos.org/manual/nixos/stable/index.html#sec-writing-modules
            { nixpkgs.overlays = overlays; }
            ./configuration.nix
            hosts/stagingvm/configuration.nix
            profiles/ssd.nix
            profiles/fde.nix
            profiles/portable.nix
            profiles/sshd.nix
            profiles/workstation.nix
            agenix.nixosModules.age
            home-manager.nixosModules.home-manager
          ];
        };
      };
    } //
      # devShell = { <system> = ./import shell.nix ... }
      flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = import nixpkgs { inherit system overlays; }; # nixpkgs with overlays applied
        in
        {
          devShell = import ./shell.nix { inherit pkgs; };
        });
}

