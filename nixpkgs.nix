# Nixpkgs config
{ self, agenix, devshell, ... } @ inputs:
{
  overlays = with self.overlays; [
    agenix.overlay # add agenix package
    devshell.overlay
    packages
    sway-im
    fcitx5
  ];
  config.allowUnfree = true;
}
