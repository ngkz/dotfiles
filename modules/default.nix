{
  base = import ./base;
  tmpfs-as-root = import ./tmpfs-as-root.nix;
  ssd = import ./ssd.nix;
  sshd = import ./sshd.nix;
  workstation = import ./workstation;
  sway-desktop = import ./sway-desktop.nix;
  undervolt = import ./undervolt.nix;
  nm-config-home = import ./nm-config-home.nix;
  vm = import ./vm.nix;
  grub-secureboot = import ./grub-secureboot;
  btrfs-maintenance = import ./btrfs-maintenance;
  nix-maintenance = import ./nix-maintenance;
  zswap = import ./zswap.nix;
  bluetooth = import ./bluetooth.nix;
  zram = import ./zram.nix;
  agenix = import ./agenix.nix;
}
