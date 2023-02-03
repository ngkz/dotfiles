# GRUB + Secure Boot
{ config, lib, pkgs, ... }:
let
  grub = pkgs.grub2.override { efiSupport = true; };
  archSuffix = ({
    x86_64-efi = "x64";
    i386-efi = "ia32";
    arm = "arm";
    aarch64 = "aa64";
  }).${grub.grubTarget};
  boot = "/boot";
  esp = config.boot.loader.efi.efiSysMountPoint;
  efiBootLoaderId = lib.replaceChars [ "/" ] [ "-" ] esp;
  bootLoaderId = "NixOS${efiBootLoaderId}";

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
    inherit boot esp;
    efiFile =
      if config.boot.loader.grub.efiInstallAsRemovable then
        "${esp}/EFI/Boot/boot${archSuffix}.efi"
      else
        "${esp}/EFI/${bootLoaderId}/grub${archSuffix}.efi";
    grubTarget = grub.grubTarget;
  };
in
{
  # hide grub password hash from unprivileged users
  fileSystems.${boot}.options = [ "fmask=077" ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    extraPrepareConfig = ''
      # grub installation process removes kernel signatures
      mkdir @bootPath@/kernels.bak
      mv @bootPath@/kernels/*.sig @bootPath@/kernels.bak
    '';
    extraInstallCommands = ''
      ${postInstall}
    '';
  };
}
