{
  base = import ./base;
  tmpfs-as-home = import ./tmpfs-as-home.nix;
  workstation = import ./workstation;
  sway-desktop = import ./sway-desktop;
}
