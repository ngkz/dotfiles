{ config, pkgs, lib, ... }:
let
  inherit (lib.ngkz) rot13;
in
{
  imports = [
    ./backup
    ./docker.nix
  ];

  # PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; with config.boot.kernelPackages; [
    turbostat
    libva-utils
    x86_energy_perf_policy
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

  programs.wireshark.enable = true;
  programs.light.enable = true;

  # Extra groups
  users.users.user.extraGroups = [
    # Wireshark
    "wireshark"
    # adb
    "adbusers"

    # light
    "video"
  ];

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "suspend";
    extraConfig = "HandlePowerKey=suspend";
  };

  services.blueman.enable = true;

  # increase maximum fan speed
  services.thinkfan = {
    enable = true;
    levels = [
      [ "level auto" 0 80 ]
      [ "level full-speed" 65 32767 ]
    ];
  };
  systemd.services.thinkfan.unitConfig.ConditionPathExists = [ "/proc/acpi/ibm/fan" ];

  hardware.trackpoint = {
    enable = true;
    speed = 255;
    device = "TPPS/2 Elan Trackpoint";
  };

  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;

  programs.adb.enable = true;
  # XXX windows network browsing function doesn't work due to https://gitlab.gnome.org/GNOME/gvfs/-/issues/506
  services.gvfs.enable = true;

  environment.variables = {
    # Enable Gstreamer hardware decoding
    GST_PLUGIN_FEATURE_RANK = "vampeg2dec:MAX,vah264dec:MAX,vah265dec:MAX,vavp8dec:MAX,vavp9dec:MAX,vaav1dec:MAX";
  };

  services.fwupd.enable = true;

  # enable all magic sysrq functions
  boot.kernel.sysctl."kernel.sysrq" = 1;

  services.udev.packages = lib.singleton (pkgs.writeTextFile
    {
      name = "udev-user-devices";
      text = ''
        # LED name badge
        SUBSYSTEMS=="usb",  ATTRS{idVendor}=="0416", ATTRS{idProduct}=="5020", TAG+="uaccess"
        # Raspberry Pi Pico in BOOTSEL mode
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0003", TAG+="uaccess"
        # Raspberry Pi Pico
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="000a", TAG+="uaccess"
        # WCH-Link
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2a86", ATTRS{idProduct}=="8011", TAG+="uaccess"
        # STM32duino
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0110", ATTRS{idProduct}=="1001", TAG+="uaccess"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0110", ATTRS{idProduct}=="1002", TAG+="uaccess"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1eaf", ATTRS{idProduct}=="0003", TAG+="uaccess", SYMLINK+="maple"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1eaf", ATTRS{idProduct}=="0004", TAG+="uaccess", SYMLINK+="maple"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5740", TAG+="uaccess"
        # FT2232H
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/71-user-devices.rules";
    });
}
