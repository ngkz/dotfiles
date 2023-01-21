# Load signed Unified Kernel Image from UEFI directly
{ config, pkgs, ... }: {
  system.build.installBootLoader = pkgs.substituteAll {
    src = ./install-bootloader.sh;
    isExecutable = true;
    inherit (pkgs) bash systemd;
    path = with pkgs; [ coreutils gnused binutils sbsigntool efibootmgr util-linux gnugrep gawk ];
    esp = config.boot.loader.efi.efiSysMountPoint;
    id = "NixOS";
    canTouchEfiVariables = config.boot.loader.efi.canTouchEfiVariables;
    age = config.age.ageBin;
    ageIdentities = builtins.concatStringsSep " " (map (path: "-i ${path}") config.age.identityPaths);
    signingKeySecret = ../../secrets/db.key.age;
    signingCertSecret = ../../secrets/db.crt.age;
    configurationLimit = 26;
  };

  # Common attribute for boot loaders so only one of them can be
  # set at once.
  system.boot.loader.id = "efistub-secureboot";
  boot.loader.grub.enable = false;
}
