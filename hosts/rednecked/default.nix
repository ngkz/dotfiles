# configuration for rednecked

{ inputs, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  imports = with inputs.nixos-hardware.nixosModules; [
    ../../modules/agenix.nix
    ../../modules/base
    ../../modules/ssd.nix
    ../../modules/sshd.nix
    ../../modules/btrfs-maintenance
    ../../modules/nix-maintenance
    ../../modules/zswap.nix

    common-pc
    common-cpu-amd #common-cpu-amd-pstate zen2 onward
    common-gpu-amd

    ./test-vm.nix
    ./hardware.nix
    ./fs
    ./user.nix
    ./network.nix
    ./pppoe.nix
    ./dnsmasq
    ./chrony
    ./wireguard.nix
    ./hardening.nix
    ./sslh.nix
    ./syncthing.nix
    ./avahi.nix
    ./ddns.nix
    ./nginx
  ];

  networking.hostName = "rednecked";

  # bootloader
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = mkDefault true;
    efiSupport = true;
    device = "nodev";
  };

  modules.sshd.allowRootLogin = true;

  # we won't use gui apps here
  fonts.fontconfig.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
