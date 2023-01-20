# GRUB + Secure Boot
{ config, lib, pkgs, ... }:
let
  grub = pkgs.grub2.override { efiSupport = true; };
  grub-mkstandalone = "${grub}/bin/grub-mkstandalone";
  grub-probe = "${grub}/bin/grub-probe";
  findmnt = "${pkgs.util-linux}/bin/findmnt";
  sbsign = "${pkgs.sbsigntool}/bin/sbsign";
  gpg = "${pkgs.gnupg}/bin/gpg";
  find = "${pkgs.findutils}/bin/find";

  age = config.age.ageBin;
  ageIdentities = builtins.concatStringsSep " " (map (path: "-i ${path}") config.age.identityPaths);

  tmpPath = "/run/grub-secureboot";
  passwordHashSecret = ../secrets/grub-password-hash.age;
  passwordHashPath = "${tmpPath}/password-hash";
  secureBootCertSecret = ../secrets/db.crt.age;
  secureBootCertPath = "${tmpPath}/db.crt";
  secureBootKeySecret = ../secrets/db.key.age;
  secureBootKeyPath = "${tmpPath}/db.key";
  gpgPrivKeySecret = ../secrets/grub.key.age;
  gpgPrivKeyPath = "${tmpPath}/grub.key";
  initialCfg = "${tmpPath}/grub-initial.cfg";
  tmpEFIPath = "${tmpPath}/boot.efi";
  efiPath =
    if config.boot.loader.grub.efiInstallAsRemovable then
      "/boot/EFI/Boot/boot*.efi"
    else
      "/boot/EFI/NixOS-boot/grub*.efi";
  gpgPubKeyPath = "${tmpPath}/grub.gpg";
in
{
  # hide grub password hash from unprivileged users
  fileSystems."/boot".options = [ "fmask=077" ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    extraInstallCommands = ''
      # agenix secrets are not yet available when installing bootloader
      # so we need to decrypt secrets manually
      rm -rf ${tmpPath}
      mkdir ${tmpPath}
      chmod 700 ${tmpPath}

      # input output
      decrypt() {
        echo >"$2"
        chmod 400 "$2"
        ${age} --decrypt ${ageIdentities} -o "$2" "$1"
      }

      decrypt ${passwordHashSecret} ${passwordHashPath}
      decrypt ${secureBootCertSecret} ${secureBootCertPath}
      decrypt ${secureBootKeySecret} ${secureBootKeyPath}
      decrypt ${gpgPrivKeySecret} ${gpgPrivKeyPath}

      cat <<EOS >${initialCfg}
      # Enforce that all loaded files must have a valid signature.
      set check_signatures=enforce
      export check_signatures

      # Disable unautiorized access to CLI and menu entries except default one
      set superusers="root"
      export superusers
      password_pbkdf2 root $(<${passwordHashPath})

      # NOTE: We export check_signatures/superusers so they are available in all
      # further contexts to ensure the password check is always enforced.

      # First partition on first disk, most likely EFI system partition. Set it here
      # as fallback in case the search doesn't find the given UUID.
      set root='hd0,gpt1'
      search --no-floppy --fs-uuid --set=root $(${findmnt} -fno UUID /boot)
      # example, see below: search --no-floppy --fs-uuid --set=root 891F-FF86

      configfile /grub/grub.cfg

      # Without this we provide the attacker with a rescue shell if he just presses
      # <return> twice.
      echo /boot/grub/grub.cfg did not boot the system but returned to initial.cfg.
      echo Rebooting the system in 10 seconds.
      sleep 10
      reboot
      EOS

      old_gnupghome=$GNUPGHOME
      export GNUPGHOME=${tmpPath}/gnupg
      mkdir "$GNUPGHOME"
      chmod 700 "$GNUPGHOME"

      ${gpg} --import ${gpgPrivKeyPath} &>/dev/null
      ${find} /boot ! -path "/boot/EFI/*" -type f -name "*.sig" -delete
      ${find} /boot ! -path "/boot/EFI/*" -type f -exec ${gpg} --detach-sign {} \; >/dev/null
      ${gpg} --detach-sign ${initialCfg} >/dev/null
      ${gpg} --export >${gpgPubKeyPath}

      export GNUPGHOME=$old_gnupghome

      ${grub-mkstandalone} \
        --format ${grub.grubTarget} \
        --modules "part_$(${grub-probe} -t partmap /boot)
                   $(${grub-probe} -t abstraction /boot)
                   $(${grub-probe} -t fs /boot)
                   pgp gcry_sha512 gcry_rsa
                   password_pbkdf2
                   configfile
                   echo reboot sleep
                   search search_fs_uuid" \
        --pubkey ${gpgPubKeyPath} \
        --disable-shim-lock \
        --output ${tmpEFIPath} \
        "boot/grub/grub.cfg=${initialCfg}" \
        "boot/grub/grub.cfg.sig=${initialCfg}.sig"

      ${sbsign} --cert ${secureBootCertPath} --key ${secureBootKeyPath} \
                --output ${efiPath} ${tmpEFIPath} >/dev/null

      rm -rf ${tmpPath}
    '';
  };
}
