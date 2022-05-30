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
      # ccache
      programs.ccache.packageNames = [ "linux_5_15_hardened" ];
      # XXX Use kernel >=5.14 for safer SMT and hyper-v drm driver
      boot.kernelPackages = pkgs.linuxPackages_5_15_hardened;
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

