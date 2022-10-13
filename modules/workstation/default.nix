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

  programs.ssh =
    let
      askPassword = "${pkgs.ngkz.gnome-ssh-askpass3}/libexec/gnome-ssh-askpass3";
      #XXX https://github.com/NixOS/nixpkgs/pull/195377
      askPasswordWrapper2 = pkgs.writeScript "ssh-askpass-wrapper2"
        ''
          #! ${pkgs.runtimeShell} -e
          export DISPLAY="$(systemctl --user show-environment | ${pkgs.gnused}/bin/sed 's/^DISPLAY=\(.*\)/\1/; t; d')"
          export WAYLAND_DISPLAY="$(systemctl --user show-environment | ${pkgs.gnused}/bin/sed 's/^WAYLAND_DISPLAY=\(.*\)/\1/; t; d')"
          exec ${askPassword} "$@"
        '';
    in
    {
      enableAskPassword = true;
      askPassword = "${askPasswordWrapper2}";
      startAgent = true;
      knownHosts = {
        "github.com".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
        "[peregrine.local]:35822".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6fsHDfhNCH1nCHQ3QH45pD/5ZQVyZYe2zvvD0dWunrUSujVOme0D8RIDl9oMy2Mp7x+W7oYaJE6hCoSMSg2JJVjZyNQC313JAUsH0lUHkGCmiNUwKxGkpgR7T3Y5IRYoN6jdWpmIext/ry0Ig2WjUTdR0m10J4OAi1ZFa6dOsXHMm4NvU5xO58UqB/fMTaTFX2aghGknD2ChcwkI7W6xIcPgVXG9UNo7rh84KmDDrtxjCns01vRwrCU4RYgWmWGOhpF89vbfkPA38sa70p2/g9TasdUo0Hm+X0i0UMOr0fdkol0UuOnLw8gnU7JQvpI9pVSwj4M+l1SjmKFl5GD8QJyrbekkQNlFBWuMQoZxtweJL6FD12xjlLsk4kmbhyNCtUXIWClVxKuYCbg7hChB8Dm9MJg0/gj/0K72oC21YAmYOuxTBZU0DdvhAuPtj0oLL7+F0j6xqlFtOIgr81zqVod4ilpDvXlo58Vlov5C8Yy6w+/q53qTblipzJoloOJJj0RVZUpkDrd1cmAxyRJ9n7wxnkrbBPftEwGSWeQ43FF23RycXEYYzrb7ZDfL6dMjYUhd5OB856ITDFK7HwPvRoyqv6jRO3gI1zjEQbPhIjdmsImVe9Tik2EYUzL8KxeVJSqiyodYpagTtMRBHn+jrXrnUp4WWaarpoDL0iXOIJQ==";
        "gitlab.com".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsj2bNKTBSpIYDEGk9KxsGh3mySTRgMtXL583qmBpzeQ+jqCMRgBqB98u3z++J1sKlXHWfM9dyhSevkMwSbhoR8XIq/U0tCNyokEi/ueaBMCvbcTHhO7FcwzY92WK4Yt0aGROY5qX2UKSeOvuP4D6TPqKF1onrSzH9bx9XUf2lEdWT/ia1NEKjunUqu1xOB/StKDHMoX4/OKyIzuS0q/T1zOATthvasJFoPrAjkohTyaDUz2LN5JoH839hViyEG82yB+MjcFV5MU3N1l1QL3cVUCh93xSaua1N85qivl+siMkPGbO5xR/En4iEY6K2XPASUEMaieWVNTRCtJ4S8H+9";
        "[tsukuba.niwase.net]:49224".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAtn+FDP8kwp4eupXEwJ671ll+D+EeNhW8IR1ZDgWY6o9oh1cTBE+rfvaJXiRYo2JSHJMHGchb2vLYr+B5+HaqrjLm4evGLy2kMqgnGFjzo8s650VEaZBWNPMjRknvprs9WEFFq0qrKYoiu82Fy+XCrqDe2bQ9yXbEcH4Se8/T5Kf+f18wlT8g97dZyrK1z0gsezGcZ+xBWpboTz0a1lr29MtBsjMdktMM1LMpPm5snF98mIlcek2FzLRx50YLQKT3aCg9hxL6N5an4tfsU55auYwGy3VUFfhXr+slR+SSxM2bAbKw3QIAiNF1iCsc0Pq9aGxyoOV7RVOkAQlO2o7T";
        "[seychelles.local]:35822".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCmXEBgFnqeKaOkjc/8DHzrZH6SuhG2YyNmOTLvSq215dv15JiJ1iPQHvi90XVJRutcPB7fbbdBs56MDCm9BqsoTImLpttbkbeUlgna1fcVAQT4U1nBZcNTnbelBHgOmBBwJtuIR33ng/noiemlTocBg04XD0GDa8mt96ujoNGUmzVza22ezkKt85gZHgDXEDxA0gskr8l9aXsCvZWb6TI+kQHiMmo0OPgtQjJykySbwfnKosN7qfUdEnH92RRXfcsQgJ0Hzoye4g4rw9ZDXcDfNnFznOAP11V3I3SMS7cjkwX3HCe9+Hw38cZAaHL2hch0wjwy54X01+3sfFb3o8ZbQJqCBYKlYkTUp/l3WhFPlhCo5N2fjSk9QGDdaoKez4U5plvms0QsiqzB97dXe9KFy2CEIbnOgl3KcDSHzN3qalWkOnF2uZxaPSiWRiy92BgejOmTaAHFAE037dJYtg98AeTOzVYYIKrb7hkHsPdTSVTOe1eIgH3j7CnE//67ac0=";
        "10.1.1.10".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/TxT5vseWfyqxTgpiXudJdRPvCTpWmum3U0WLTkuCxaOTIY690o2W0Jyhtl1WhGWiBXJp6tGod4dojHIcCnXfkO6Dk2Oy61P/iMtd4JL4D48lklYrFB8wi20fYRmWTz5ZdlSNRghJlB8H7lyonLuCzg1OV99winb1/h4qLqLoiM72SC2AdbCEMgxPVVHk5r7xCyBEWdy8oOXcx1fhTbn0e6hz6UeT9W67yJ9fCkZDVZozb3WQriEUtnQo0cFJdaQndx9K7qkJZfxqrBxxhZYqvFCWv5yZZvX4KsW0atEBlgli0Y+WjM26Da5ggLHdJRQbMHhvevs+J61yQs9OgEJT";
        "10.1.1.6".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCWQ3OVP3teDjFHckD3zpNE0CpOpJb4hJMYBkZK+US6brRMNZPUW6v/9mxagk7cYcmaxoQ0/W4VM+5+MHYiOIgOIjF+jdA9CD7J/97vMCGmBU9fxwJYjatAKnVpPN40qSX9SjynNCa5X82gOMSw8BzEXH1xFc4BuaYGyySQ8jbFxolrp3/qhwAXPJxzOQlmnu4PhLfCPN9s9mJigIrUY80mdV3J5ZfdLBdxFitlUqayp35tOwuoKgqzOwUhSCAvfN78BlQRPKTB6GJV3UY8ie3ud4qFRkwauejlpZyH6XxPL+3/fBHsza93yNzAAcoZlL6ENrX7+4F1lszYjTecBaF7";
        "172.16.34.4".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhwB8N2NoopR0AsZTJ1g0lTVN4OHGEhYvitKNuffdsfqiQ4gKNVOqT+UXfuv4XZH5IQkWlWBnavNItS6WB9NNarPTIkgs0B0M/sZsriF/59cXARkm9LeW0ClB6mEZmP58mW8smmny5pFWovU4GomX19s6j4aJMtB16hc49JiVAt3eNL5QcPmXoq1VGzg9MdLGz4Z5ikaNEtrpXIylNbLFRHg91toTBI7F1N8v+xlVrEHTtCIa9Ue0WoCmix8QuIRPAaSpep1/ahjtdMRYyL82j/NL8uOs7/FD0sEGv1+03BLU/esLCaTR5ZBZobisZF5uVfSqSCsreYRc7GDyW2upb";
        "172.16.34.5".publicKey = "172.16.34.5 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCP0U4++TCUnvx9m0WtSuy7unNGQlm+LXgZAz4UF8qcsfi/k5hwmT7vs1569j/+I+FAqianz7RJPK/WMqvXtH6BujbXCfCNs4MhKxVGPZI0Mx+31PLQEkAq7HVQtmZJOHlg4v0zUoxth57SRz6t3i2dUo/eaTThZXRYeHlI4RBpCyRRODPgwwuLTs7ep43w9CVeYVehX9A2Qg6OdnQ18U7PQw7nsj8F6zsFLEuWM1BMYo/bVNz9rZPqcGRNlrXjFzeIcfk3f1A4HRVSAP16SGz7UBvweS1vvJHVJwVIh5XCuV/hVsoToEnw7kobBJd3JgpLHm+TzlN9yzUH6LcfyfSp";
        "172.16.34.6".publicKey = "172.16.34.6 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1kR4DQ9ogIHYjR9TbWj1JC3am26+goTSamOx4pIgCKZ+rgqiFreztx+Vf4d7MTkAD3ijCbz/L5QrAhujff2aJXRRrb73q5qS03uQdeA5w9b1xLqggW7yUAW2uMT2MY/x2XHeIG55zwZrb1S9Ggwp7JSc2Xneiqf5TwAulbVnts07feMauFmFzkxAnVy7e8GKjZRF10ZRlXHgRxCPXIwXlo8IBXdFERatk4W9mLUd8o/27AyRHjPvA5tkIpczZqabBTzDve6JB2pL1cZt8xCS0Qu3M0H4e46PlnWSzPDhIQK5IzEfVyhkZgW+uWXoN0MVZTD3z8xGfoMwviqViA7I1";
        "172.16.34.7".publicKey = "172.16.34.7 ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAE9SRVqhTt+uZcwimnHKWq/x9mpt6vrbzc+3ElM2GMHzlY+8qFh02RltnNPR2oJhACX4ebLBPdbPr4ko4wAJgQQHAEw/MCebiJE0a60yd5b5g6ztDk9MmKX1E1boCY8ko5mCnq6VWhnajRpb2Spn78qnuLA5icMNw5gOCxqutikFDhoew==";
        "172.16.34.8".publicKey = "172.16.34.8 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzDLUNdcvEUrz2cxk17ky+U+n/qAseH3hCLlZcGMEPvoVRsBdhRTDuMjluvPsueOGptykxKx8LzzwXMVTA8Bh8ZqifA5Ps1uxhMcurjEbQIxF6CtR6JsOuBroKfQg7JL72WwytCsZ3o99rLvnXse3qHIMVlIza31wGDPNHcQ+p8XB8SsSXah185yHUphhq10b7fGUtD7eMqms+VgcFyOfMoTHl4wbJYhLPNniiKaI4r8htYXwkUC8JLtCltz2M06jtl//GspCdAfNqYsFd+idWGrlcj/bDQ8BuxdXMF9Cx11sNCu4MvjvxpcMLhicQAvkaogMeOlfcPvKQVr51caHH";
      };
    };

  programs.adb.enable = true;
}
