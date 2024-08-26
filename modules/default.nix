{
  base = import ./base.nix;
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
  users = import ./users.nix;
  sudo = import ./sudo.nix;
  home-manager = import ./home-manager.nix;
  sysctl-tweaks = import ./sysctl-tweaks.nix;
  mdns = import ./mdns.nix;
  update-users-groups-bug-workaround = import ./update-users-groups-bug-workaround;
  disable-usb-keyboard-wakeup = import ./disable-usb-keyboard-wakeup.nix;
  fonts = import ./fonts.nix;
  zsh = import ./zsh.nix;
  desktop-essential = import ./desktop-essential.nix;
  print-and-scan = import ./print-and-scan.nix;
  tailscale-common = import ./tailscale/common.nix;
  tailscale-client = import ./tailscale/client.nix;
  syncthing-user = import ./syncthing-user.nix;
}
