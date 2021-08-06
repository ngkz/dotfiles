# GRUB + Full Disk Encryption including /boot + Secure Boot (WIP)
{ config, lib, inputs, ... }:
let
  inherit (lib) mkOption types;
in {
  imports = [
    inputs.self.nixosModules.grub
  ];

  options.modules.grub-fde.cryptlvmDevice = mkOption {
    type = types.str;
    description = "Underlying device of encrypted LVM PV";
  };

  config = let 
    cfg = config.modules.grub-fde;
  in {
    boot = {
      loader.grub.enableCryptodisk = true;

      initrd = {
        # Early boot AES acceleration
        availableKernelModules = [ "aesni_intel" ];

        luks.devices."cryptlvm" = {
          preLVM = true;
          keyFile = "/cryptlvm.key";
          allowDiscards = true;
          device = cfg.cryptlvmDevice;
        };

        secrets = {
          "cryptlvm.key" = "/nix/persist/secrets/cryptlvm.key";
        };
      };
    };
  };

  # TODO Does GRUB drop to rescue shell when the password input is skipped even if secure boot is enabled?
  # https://ruderich.org/simon/notes/secure-boot-with-grub-and-signed-linux-and-initrd
  # TODO secure boot
  # TODO trusted boot
  # hook system.build.installBootLoader
}
