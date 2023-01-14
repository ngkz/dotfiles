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
  efistub-secureboot = import ./efistub-secureboot;
}
