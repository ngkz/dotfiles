# Full Disk Encryption + Secure Boot
{ config, pkgs, ... }:
{
  boot = {
    loader = {
      grub = {
        enableCryptodisk = true;
        users.root = {
          hashedPasswordFile = config.age.secrets.grub-password-hash.path;
        };
      };
    };

    initrd = {
      # Early boot AES acceleration
      availableKernelModules = [ "aesni_intel" ];

      luks = {
        devices."cryptlvm" = {
          preLVM = true;
          keyFile = "/cryptlvm.key";
          allowDiscards = true;
        };
      };

      secrets = {
        "cryptlvm.key" = "/nix/persist/secrets/cryptlvm.key";
      };
    };
  };

  # TODO Does GRUB drop to rescue shell when the password input is skipped even if secure boot is enabled?
  # https://ruderich.org/simon/notes/secure-boot-with-grub-and-signed-linux-and-initrd
  # TODO secure boot
  # TODO trusted boot
  # hook system.build.installBootLoader
}
