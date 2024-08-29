# Nixpkgs config
{ self, agenix, devshell, ... } @ inputs:
{
  overlays = with self.overlays; [
    agenix.overlays.default # add agenix package
    devshell.overlays.default
    packages
    sway-im
    fcitx5
    unstable
  ];
  config.allowUnfree = true;
  flake = {
    # conflicts with modules/nix.nix
    setFlakeRegistry = false;
    setNixPath = false;
  };
}
