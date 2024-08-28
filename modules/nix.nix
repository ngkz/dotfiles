# nix configuration
{ lib, pkgs, inputs, ... }:

let
  inherit (lib) mkIf filterAttrs mapAttrsToList mapAttrs;
  inherit (inputs) self;
in
{
  nixpkgs = import ../nixpkgs.nix inputs;

  # Enable experimental flakes feature
  nix =
    let
      filteredInputs = filterAttrs (n: _: n != "self") inputs;
      nixPathInputs = mapAttrsToList (n: v: "${n}=${v}") filteredInputs;
      registryInputs = mapAttrs (_: v: { flake = v; }) filteredInputs;
    in
    {
      # Enable flake
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes

        # Keep build-time dependencies when GC
        # keep-outputs = true
        # keep-derivations = true
      '';

      settings = {
        # Only allow administrative users to connect the nix daemon
        allowed-users = [ "root" "@wheel" ];

        trusted-users = [ "root" ];

        # max-jobs = 1; # XXX default max-jobs causes memory exhaustion

        # substituters = [
        #   "http://peregrine.local:5000"
        # ];

        trusted-public-keys = [
          "peregrine:ttyus2jSLVWOMNfGkwgC71iJ36DZgJINICtkdUMeg8k="
        ];
      };

      # turned autoOptimiseStore and gc.automatic off due to slowdown

      # pin flakes to the exact version used to build the system
      registry = registryInputs // { dotfiles.flake = inputs.self; };

      nixPath = nixPathInputs ++ [
        "dotfiles=${inputs.self}"
      ];
    };

  # Let 'nixos-version --json' know the Git revision of this flake.
  system.configurationRevision = mkIf (self ? rev) self.rev;

  # build packages on the disk
  systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";
}
