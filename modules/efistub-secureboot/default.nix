# Load signed Unified Kernel Image from UEFI directly
{ config, lib, pkgs, ... }: {
  system.build.installBootLoader = pkgs.substituteAll {
    src = ./install-bootloader.sh;
    isExecutable = true;
    inherit (pkgs) bash systemd;
    path = with pkgs; [ coreutils gnused binutils sbsigntool efibootmgr util-linux gnugrep gawk ];
    esp = config.boot.loader.efi.efiSysMountPoint;
    id = "NixOS";
    canTouchEfiVariables = config.boot.loader.efi.canTouchEfiVariables;
    signingKey = "${config.modules.tmpfs-as-root.storage}/secrets/db.key";
    signingCert = "${config.modules.tmpfs-as-root.storage}/secrets/db.crt";
  };

  # Common attribute for boot loaders so only one of them can be
  # set at once.
  system.boot.loader.id = "efistub-secureboot";
  boot.loader.grub.enable = false;
}
