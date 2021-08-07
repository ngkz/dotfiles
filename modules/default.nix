{
  base = import ./base.nix;
  tmpfs-as-root = import ./tmpfs-as-root.nix;
  grub-fde = import ./grub-fde.nix;
  portable = import ./portable.nix;
  ssd = import ./ssd.nix;
  sshd = import ./sshd.nix;
  workstation = import ./workstation;
}
