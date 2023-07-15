{
  core = import ./core.nix;
  base = import ./base;
  tmpfs-as-home = import ./tmpfs-as-home.nix;
  workstation = import ./workstation;
  sway-desktop = import ./sway-desktop;
  theming = import ./theming;
  neovim = import ./neovim;
  hacking = import ./hacking;
}
