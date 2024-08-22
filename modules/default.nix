{
  base = import ./base;
  tmpfs-as-root = import ./tmpfs-as-root.nix;
  ssd = import ./ssd.nix;
  sshd = import ./sshd.nix;
  workstation = import ./workstation;
  sway-desktop = import ./sway-desktop.nix;
  undervolt = import ./undervolt.nix;
  vmm = import ./vmm.nix;
  grub-secureboot = import ./grub-secureboot;
  btrfs-maintenance = import ./btrfs-maintenance;
  nix-maintenance = import ./nix-maintenance;
  zswap = import ./zswap.nix;
  bluetooth = import ./bluetooth.nix;
  zram = import ./zram.nix;
  agenix = import ./agenix.nix;
  libvirt-vm = import ./libvirt-vm;
  profiles-intel-cpu = import ./profiles/intel-cpu.nix;
  profiles-intel-wifi = import ./profiles/intel-wifi.nix;
  profiles-laptop = import ./profiles/laptop.nix;
  network-manager = import ./network-manager;
  binary-cache = import ./binary-cache.nix;
  console = import ./console.nix;
  nix = import ./nix.nix;
}
