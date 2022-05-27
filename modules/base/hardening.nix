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
    };
  };

  imports = [
    "${nixpkgs}/nixos/modules/profiles/hardened.nix"
  ];

  config = mkMerge [
    {
      # additional hardening
      # XXX Use kernel >=5.14 for safer SMT and hyper-v drm driver
      boot.kernelPackages = pkgs.linuxPackages_5_15_hardened;
      boot.kernelPatches = [
        {
          name = "reenable-devmem";
          patch = null;
          # intel-undervolt needs /dev/mem
          extraConfig = ''
            DEVMEM y
            STRICT_DEVMEM y
            IO_STRICT_DEVMEM y
            LOGO y
          '';
        }
      ];
      # hardened.nix disables SMT
      security.allowSimultaneousMultithreading = true;
      # security.protectKernelImage disables hibernation
      security.protectKernelImage = false;
      # Prevent replacing the running kernel image w/o reboot
      boot.kernel.sysctl."kernel.kexec_load_disabled" = true;
      # XXX custom allocator doesn't work with unstable packages
      environment.memoryAllocator.provider = "libc";
      security.chromiumSuidSandbox.enable = true;
      services.dbus.apparmor = "enabled";
    }
    (mkIf cfg.disableMeltdownAndL1TFMitigation {
      # hardened.nix forces flushL1DataCache and KPTI
      security.virtualisation.flushL1DataCache = null;
      security.forcePageTableIsolation = false;
    })
  ];
}

