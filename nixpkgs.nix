# Nixpkgs config
{ self, nixpkgs-unstable, agenix, devshell, ... } @ inputs:
{
  overlays = with self.overlays; [
    agenix.overlay # add agenix package
    devshell.overlay
    unstable
    packages
    sway-im
    latest-fcitx5
  ];
  config.allowUnfree = true;
}
