{ config, pkgs, lib, ... }: {
  imports = [
    ./printing.nix
    ./network-manager.nix
    ./gpg.nix
  ];

  # PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # mDNS
  services.avahi = {
    enable = true;
    nssmdns = true; # *.local resolution
    publish.enable = true;
    publish.addresses = true; # make this host accessible with <hostname>.local
  };

  environment.systemPackages = with pkgs; with linuxPackages; [
    turbostat
    libva-utils
  ];

  # install fonts
  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji-blob-bin
      corefonts
      dejavu_fonts
      freefont_ttf
      gyre-fonts # TrueType substitutes for standard PostScript fonts
      liberation_ttf
      unifont
      ibm-plex
      ngkz.sarasa-term-j-nerd-font
    ];

    # Create a directory with links to all fonts in /run/current-system/sw/share/X11/fonts
    fontDir.enable = true;

    fontconfig = {
      defaultFonts = {
        sansSerif = [ "IBM Plex Sans JP" ];
        serif = [
          "IBM Plex Serif"
          "Noto Serif CJK JP"
        ];
        emoji = [ "Blobmoji" ];
        monospace = [ "Sarasa Term J Nerd Font" ];
      };
      cache32Bit = true;
      # XXX Workaround for nixpkgs#46323
      localConf = builtins.readFile "${pkgs.ngkz.blobmoji-fontconfig}/etc/fonts/conf.d/75-blobmoji.conf";
    };
  };

  programs.wireshark.enable = true;
  programs.light.enable = true;

  # Extra groups
  users.users.user.extraGroups = [
    # Wireshark
    "wireshark"

    # light
    "video"
  ];

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "suspend";
    extraConfig = "HandlePowerKey=suspend";
  };

  services.upower.enable = true;
  modules.tmpfs-as-root.persistentDirs = [ "/var/lib/upower" ];
  systemd.services.upower.serviceConfig = {
    StateDirectory = "";
    ReadWritePaths = [
      "/var/lib/upower"
      "${config.modules.tmpfs-as-root.storage}/var/lib/upower"
    ];
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

  # install debug symbols
  environment.enableDebugInfo = true;

  # Syncthing
  networking.firewall = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 21027 22000 ];
  };

  age.secrets.syncthing = {
    file = ../../secrets/syncthing.json.age;
    owner = "user";
    group = "users";
    mode = "0400";
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
    knownHosts = {
      "github.com".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
      "[peregrine.local]:35822".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6fsHDfhNCH1nCHQ3QH45pD/5ZQVyZYe2zvvD0dWunrUSujVOme0D8RIDl9oMy2Mp7x+W7oYaJE6hCoSMSg2JJVjZyNQC313JAUsH0lUHkGCmiNUwKxGkpgR7T3Y5IRYoN6jdWpmIext/ry0Ig2WjUTdR0m10J4OAi1ZFa6dOsXHMm4NvU5xO58UqB/fMTaTFX2aghGknD2ChcwkI7W6xIcPgVXG9UNo7rh84KmDDrtxjCns01vRwrCU4RYgWmWGOhpF89vbfkPA38sa70p2/g9TasdUo0Hm+X0i0UMOr0fdkol0UuOnLw8gnU7JQvpI9pVSwj4M+l1SjmKFl5GD8QJyrbekkQNlFBWuMQoZxtweJL6FD12xjlLsk4kmbhyNCtUXIWClVxKuYCbg7hChB8Dm9MJg0/gj/0K72oC21YAmYOuxTBZU0DdvhAuPtj0oLL7+F0j6xqlFtOIgr81zqVod4ilpDvXlo58Vlov5C8Yy6w+/q53qTblipzJoloOJJj0RVZUpkDrd1cmAxyRJ9n7wxnkrbBPftEwGSWeQ43FF23RycXEYYzrb7ZDfL6dMjYUhd5OB856ITDFK7HwPvRoyqv6jRO3gI1zjEQbPhIjdmsImVe9Tik2EYUzL8KxeVJSqiyodYpagTtMRBHn+jrXrnUp4WWaarpoDL0iXOIJQ==";
      "gitlab.com".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsj2bNKTBSpIYDEGk9KxsGh3mySTRgMtXL583qmBpzeQ+jqCMRgBqB98u3z++J1sKlXHWfM9dyhSevkMwSbhoR8XIq/U0tCNyokEi/ueaBMCvbcTHhO7FcwzY92WK4Yt0aGROY5qX2UKSeOvuP4D6TPqKF1onrSzH9bx9XUf2lEdWT/ia1NEKjunUqu1xOB/StKDHMoX4/OKyIzuS0q/T1zOATthvasJFoPrAjkohTyaDUz2LN5JoH839hViyEG82yB+MjcFV5MU3N1l1QL3cVUCh93xSaua1N85qivl+siMkPGbO5xR/En4iEY6K2XPASUEMaieWVNTRCtJ4S8H+9";
      "[tsukuba.niwase.net]:49224".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAtn+FDP8kwp4eupXEwJ671ll+D+EeNhW8IR1ZDgWY6o9oh1cTBE+rfvaJXiRYo2JSHJMHGchb2vLYr+B5+HaqrjLm4evGLy2kMqgnGFjzo8s650VEaZBWNPMjRknvprs9WEFFq0qrKYoiu82Fy+XCrqDe2bQ9yXbEcH4Se8/T5Kf+f18wlT8g97dZyrK1z0gsezGcZ+xBWpboTz0a1lr29MtBsjMdktMM1LMpPm5snF98mIlcek2FzLRx50YLQKT3aCg9hxL6N5an4tfsU55auYwGy3VUFfhXr+slR+SSxM2bAbKw3QIAiNF1iCsc0Pq9aGxyoOV7RVOkAQlO2o7T";
      "[seychelles.local]:35822".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCmXEBgFnqeKaOkjc/8DHzrZH6SuhG2YyNmOTLvSq215dv15JiJ1iPQHvi90XVJRutcPB7fbbdBs56MDCm9BqsoTImLpttbkbeUlgna1fcVAQT4U1nBZcNTnbelBHgOmBBwJtuIR33ng/noiemlTocBg04XD0GDa8mt96ujoNGUmzVza22ezkKt85gZHgDXEDxA0gskr8l9aXsCvZWb6TI+kQHiMmo0OPgtQjJykySbwfnKosN7qfUdEnH92RRXfcsQgJ0Hzoye4g4rw9ZDXcDfNnFznOAP11V3I3SMS7cjkwX3HCe9+Hw38cZAaHL2hch0wjwy54X01+3sfFb3o8ZbQJqCBYKlYkTUp/l3WhFPlhCo5N2fjSk9QGDdaoKez4U5plvms0QsiqzB97dXe9KFy2CEIbnOgl3KcDSHzN3qalWkOnF2uZxaPSiWRiy92BgejOmTaAHFAE037dJYtg98AeTOzVYYIKrb7hkHsPdTSVTOe1eIgH3j7CnE//67ac0=";
    };
  };
}
