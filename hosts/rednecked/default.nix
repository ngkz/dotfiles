# configuration for rednecked

{ inputs, pkgs, lib, config, ... }:
let
  inherit (lib) mkDefault;
in
{
  imports = with inputs.nixos-hardware.nixosModules; [
    ../../modules/agenix.nix
    ../../modules/base.nix
    ../../modules/console.nix
    ../../modules/ssd.nix
    ../../modules/sshd.nix
    ../../modules/btrfs-maintenance
    ../../modules/nix-maintenance
    ../../modules/zswap.nix
    ../../modules/mdns.nix

    common-pc
    common-cpu-amd #common-cpu-amd-pstate zen2 onward
    common-gpu-amd

    ./test-vm.nix
    ./hardware.nix
    ./fs
    ./user.nix
    ./network.nix
    ./hardening.nix
    ./syncthing.nix
    ./tailscale.nix
    ./borg.nix
  ];

  networking.hostName = "rednecked";

  # bootloader
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = mkDefault true;
    efiSupport = true;
    device = "nodev";
  };

  modules.sshd.allowRootLogin = true; # switch-remote
  services.openssh.openFirewall = false;
  hosts.rednecked.network.internalInterfaces.allowedTCPPorts = config.services.openssh.ports;
  services.openssh.settings.GatewayPorts = "clientspecified";

  # we won't use gui apps here
  fonts.fontconfig.enable = false;

  # do not enter emergency mode (and kill everythin including tailscale and sshd) when filesystem mounting failure
  systemd.enableEmergencyMode = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
