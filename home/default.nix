{
  nixos = import ./nixos.nix;
  base = import ./base;
  tealdeer = import ./tealdeer.nix;
  tmpfs-as-home = import ./tmpfs-as-home.nix;
  workstation = import ./workstation;
  sway-desktop = import ./sway-desktop;
  theming = import ./theming;
  neovim = import ./neovim;
  hacking = import ./hacking;
  vmm = import ./vmm.nix;
}
