# Nixpkgs config
{ self, agenix, devshell, ... } @ inputs:
{
  overlays = with self.overlays; [
    agenix.overlays.default # add agenix package
    devshell.overlays.default
    packages
    fcitx5
    unstable
  ];
  config.allowUnfree = true;
}
