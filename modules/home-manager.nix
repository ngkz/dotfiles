# home-manager
{ lib, inputs, ... }:

let
  inherit (inputs) home-manager;
in
{
  imports = [ home-manager.nixosModule ];

  # home-manager
  home-manager = {
    useGlobalPkgs = true; # use global nixpkgs
    # install per-user packages to /etc/profiles to make nixos-rebuild build-vm work
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      lib = lib.extend (_: _: home-manager.lib); # lib.ngkz
    };
  };
}
