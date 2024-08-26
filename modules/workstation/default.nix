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
      [ "level auto" 0 70 ]
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

  hardware.opengl.extraPackages = with pkgs; [
    intel-compute-runtime
    intel-ocl
  ];

  programs.ssh = {
    enableAskPassword = true;
    askPassword = "${pkgs.ngkz.gnome-ssh-askpass3}/libexec/gnome-ssh-askpass3";
    startAgent = true;
    # forwardX11 = true;
    knownHosts = {
      "github.com".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
      "peregrine.falcon-nunki.ts.net".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6fsHDfhNCH1nCHQ3QH45pD/5ZQVyZYe2zvvD0dWunrUSujVOme0D8RIDl9oMy2Mp7x+W7oYaJE6hCoSMSg2JJVjZyNQC313JAUsH0lUHkGCmiNUwKxGkpgR7T3Y5IRYoN6jdWpmIext/ry0Ig2WjUTdR0m10J4OAi1ZFa6dOsXHMm4NvU5xO58UqB/fMTaTFX2aghGknD2ChcwkI7W6xIcPgVXG9UNo7rh84KmDDrtxjCns01vRwrCU4RYgWmWGOhpF89vbfkPA38sa70p2/g9TasdUo0Hm+X0i0UMOr0fdkol0UuOnLw8gnU7JQvpI9pVSwj4M+l1SjmKFl5GD8QJyrbekkQNlFBWuMQoZxtweJL6FD12xjlLsk4kmbhyNCtUXIWClVxKuYCbg7hChB8Dm9MJg0/gj/0K72oC21YAmYOuxTBZU0DdvhAuPtj0oLL7+F0j6xqlFtOIgr81zqVod4ilpDvXlo58Vlov5C8Yy6w+/q53qTblipzJoloOJJj0RVZUpkDrd1cmAxyRJ9n7wxnkrbBPftEwGSWeQ43FF23RycXEYYzrb7ZDfL6dMjYUhd5OB856ITDFK7HwPvRoyqv6jRO3gI1zjEQbPhIjdmsImVe9Tik2EYUzL8KxeVJSqiyodYpagTtMRBHn+jrXrnUp4WWaarpoDL0iXOIJQ==";
      "gitlab.com".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsj2bNKTBSpIYDEGk9KxsGh3mySTRgMtXL583qmBpzeQ+jqCMRgBqB98u3z++J1sKlXHWfM9dyhSevkMwSbhoR8XIq/U0tCNyokEi/ueaBMCvbcTHhO7FcwzY92WK4Yt0aGROY5qX2UKSeOvuP4D6TPqKF1onrSzH9bx9XUf2lEdWT/ia1NEKjunUqu1xOB/StKDHMoX4/OKyIzuS0q/T1zOATthvasJFoPrAjkohTyaDUz2LN5JoH839hViyEG82yB+MjcFV5MU3N1l1QL3cVUCh93xSaua1N85qivl+siMkPGbO5xR/En4iEY6K2XPASUEMaieWVNTRCtJ4S8H+9";
      "${rot13 "[gfhxhon.avjnfr.arg]:49224"}".publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBF9L6WVElJnpK7zRmZdk7aYJc0z4zrZcXd0AjkqMPBnpXGL6V3pIGdDl1fRuGeeHGCif958fLcpOSzU+v2g5uEI=";
      "rednecked.falcon-nunki.ts.net".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILPl2FFAlSd2EMv+Cx6Floei91AmTUix119a7Npm3axF";
    };
  };

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

  services.udev.extraRules = ''
    # LED name badge
    SUBSYSTEM=="usb",  ATTRS{idVendor}=="0416", ATTRS{idProduct}=="5020", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="0416", ATTRS{idProduct}=="5020", ATTRS{busnum}=="1", MODE="0666"
  '';
}
