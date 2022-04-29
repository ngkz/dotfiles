# GRUB + Full Disk Encryption including /boot + Secure Boot (WIP)
{ config, lib, inputs, pkgs, ... }:
let
  inherit (lib) mkOption types escapeShellArg replaceChars;
in
{
  options.modules.grub-fde = {
    cryptlvmDevice = mkOption {
      type = types.str;
      description = "Underlying device of encrypted LVM PV";
    };

    espDevice = mkOption {
      type = types.str;
      description = "Path of ESP(/boot/efi) device";
    };
  };
  config =
    let
      cfg = config.modules.grub-fde;
      grub = pkgs.grub2.override { efiSupport = true; };
      realBoot = "${config.modules.tmpfs-as-root.storage}/boot";
      espMount = "${realBoot}/efi";
      bootloaderId = "NixOS" + (replaceChars [ "/" ] [ "-" ] espMount);
    in
    {
      modules.tmpfs-as-root.persistentDirs = [
        "/boot"
      ];

      fileSystems."${espMount}" = {
        device = cfg.espDevice;
        fsType = "vfat";
      };

      boot = {
        loader = {
          efi.canTouchEfiVariables = true;

          grub = {
            enable = true;
            efiSupport = true;
            enableCryptodisk = true;
            # install-grub.pl goes bananas if /boot or /nix are bind-mount or symlink
            # Relocate /boot to /nix/persist/boot
            mirroredBoots = [{
              path = realBoot;
              devices = [ "nodev" ];
              efiSysMountPoint = espMount;
            }];
            extraInstallCommands = ''
              grub_tmp=$(mktemp -d -t grub.conf.XXXXXXXX)
              trap 'rm -rf -- "$grub_tmp"' EXIT

              cat <<EOS >"$grub_tmp/grub.cfg"
                # Ask the password multiple times
                while ! cryptomount -u $(grub-probe -t cryptodisk_uuid ${escapeShellArg realBoot}); do
                  true
                done

                set root='$(${grub}/bin/grub-probe -t drive ${escapeShellArg realBoot} | ${pkgs.gnused}/bin/sed 's/^(\(.*\))$/\1/')'
                set prefix='$(${grub}/bin/grub-probe -t drive ${escapeShellArg realBoot})$(${grub}/bin/grub-mkrelpath ${escapeShellArg realBoot}/grub)'
                configfile \$prefix/grub.cfg
              EOS

              ${grub}/bin/grub-mkstandalone \
                --format=${grub.grubTarget} \
                --modules "part_$(${grub}/bin/grub-probe -t partmap ${escapeShellArg realBoot})
                           $(${grub}/bin/grub-probe -t abstraction ${escapeShellArg realBoot})
                           $(${grub}/bin/grub-probe -t fs ${escapeShellArg realBoot})
                           configfile true" \
                --output ${escapeShellArg "${espMount}/EFI/${bootloaderId}"}/grub*.efi \
                "boot/grub/grub.cfg=$grub_tmp/grub.cfg"
            '';
          };
        };

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
            "cryptlvm.key" = "${config.modules.tmpfs-as-root.storage}/secrets/cryptlvm.key";
          };
        };
      };
    };

  # https://ruderich.org/simon/notes/secure-boot-with-grub-and-signed-linux-and-initrd
  # TODO secure boot
  # TODO trusted boot
  # hook system.build.installBootLoader
}
