# Nixpkgs config
{ self, agenix, devshell, ... } @ inputs:
{
  overlays = with self.overlays; [
    agenix.overlays.default # add agenix package
    devshell.overlay
    packages
    sway-im
    fcitx5
  ];
  config.allowUnfree = true;
}
