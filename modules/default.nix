{
  base = import ./base;
  tmpfs-as-root = import ./tmpfs-as-root.nix;
  grub-fde = import ./grub-fde.nix;
  portable = import ./portable.nix;
  ssd = import ./ssd.nix;
  sshd = import ./sshd.nix;
  workstation = import ./workstation;
  sway-desktop = import ./sway-desktop.nix;
  intel-undervolt = import ./intel-undervolt.nix;
}
