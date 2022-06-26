{ pkgs, lib, inputs, config, ... }:
let
  inherit (lib) mkOption types mkMerge mkIf;
  inherit (inputs) nixpkgs;
  cfg = config.modules.hardening;
in
{
  options.modules.hardening = {
    disableMeltdownAndL1TFMitigation = mkOption {
      type = types.bool;
      description = "Disable mitigations unneeded for newer CPUs (Intel: >=Whiskey Lake)";
      default = false;
    };
  };

  imports = [
    "${nixpkgs}/nixos/modules/profiles/hardened.nix"
  ];

  config = mkMerge [
    {
      # additional hardening
      # hardened.nix disables SMT
      # kernel >=5.14 supports safer SMT
      security.allowSimultaneousMultithreading = true;
      # security.protectKernelImage disables hibernation
      security.protectKernelImage = false;
      # Prevent replacing the running kernel image w/o reboot
      boot.kernel.sysctl."kernel.kexec_load_disabled" = true;
      # custom allocator doesn't work with unstable packages
      #environment.memoryAllocator.provider = "libc";
      security.chromiumSuidSandbox.enable = true;
      services.dbus.apparmor = "enabled";
      # this fucking sucks
      security.lockKernelModules = lib.mkForce false;
    }
    (mkIf cfg.disableMeltdownAndL1TFMitigation {
      # hardened.nix forces flushL1DataCache and KPTI
      security.virtualisation.flushL1DataCache = null;
      security.forcePageTableIsolation = false;
    })
  ];
}

