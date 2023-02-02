# GRUB + Secure Boot
{ config, lib, pkgs, ... }:
let
  grub = pkgs.grub2.override { efiSupport = true; };

  postInstall = pkgs.substituteAll {
    src = ./post-install.sh;
    isExecutable = true;
    age = config.age.ageBin;
    path = with pkgs; [ coreutils grub util-linux sbsigntool gnupg findutils gawk ];
    inherit (pkgs) bash;
    ageIdentities = builtins.concatStringsSep " " (map (path: "-i ${path}") config.age.identityPaths);
    passwordHashSecret = ../../secrets/grub-password-hash.age;
    secureBootCertSecret = ../../secrets/db.crt.age;
    secureBootKeySecret = ../../secrets/db.key.age;
    gpgPrivKeySecret = ../../secrets/grub.key.age;
    efiPath =
      if config.boot.loader.grub.efiInstallAsRemovable then
        "/boot/EFI/Boot/boot*.efi"
      else
        "/boot/EFI/NixOS-boot/grub*.efi";
    grubTarget = grub.grubTarget;
  };
in
{
  # hide grub password hash from unprivileged users
  fileSystems."/boot".options = [ "fmask=077" ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    extraInstallCommands = ''
      ${postInstall}
    '';
  };
}
