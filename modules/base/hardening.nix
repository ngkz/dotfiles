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
      # hardened.nix disables SMT
      # kernel >=5.14 supports safer SMT
      security.allowSimultaneousMultithreading = true;
      # security.protectKernelImage disables hibernation
      security.protectKernelImage = false;
      # Prevent replacing the running kernel image w/o reboot
      boot.kernel.sysctl."kernel.kexec_load_disabled" = true;
      # custom allocator doesn't work with unstable packages
      #environment.memoryAllocator.provider = "libc";
      security.chromiumSuidSandbox.enable = true;
      services.dbus.apparmor = "enabled";

      # hardened.nix disables dynamic kernel module loading
      boot.kernelModules = [
        "af_packet"
        "bfq"
        "blake2b_generic"
        "btrfs"
        "cdc_acm"
        "cdc_ether"
        "cdrom"
        "cifs"
        "cifs_arc4"
        "cifs_md4"
        "crc32_generic"
        "dns_resolver"
        "exfat"
        "ext2"
        "ext4"
        "f2fs"
        "fscache"
        "ftdi_sio"
        "hid_generic"
        "hid_lenovo"
        "hidp"
        "isofs"
        "jbd2"
        "lz4_compress"
        "lz4hc_compress"
        "mbcache"
        "mii"
        "nls_utf8"
        "ntfs3"
        "r8152"
        "r8153_ecm"
        "raid6_pq"
        "sd_mod"
        "snd_rawmidi"
        "snd_seq_device"
        "snd_usb_audio"
        "snd_usbmidi_lib"
        "squashfs"
        "typec_displayport"
        "uas"
        "usb_storage"
        "usbhid"
        "usbnet"
        "usbserial"
        "xor"
        "zstd_compress"
        "des"
        "des3_ede"
      ];
    }
    (mkIf cfg.disableMeltdownAndL1TFMitigation {
      # hardened.nix forces flushL1DataCache and KPTI
      security.virtualisation.flushL1DataCache = null;
      security.forcePageTableIsolation = false;
    })
  ];
}

