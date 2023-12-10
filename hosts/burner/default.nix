# configuration for ctfvm

{ config, lib, pkgs, inputs, ... }:
let
  inherit (lib) mkForce;
  inherit (inputs) self;
in
{
  networking.hostName = "burner";

  imports = with self.nixosModules; [
    base
    sshd
    libvirt-vm
    hacking
  ];

  modules.libvirt-vm = {
    memorySize = 8192;
    disks = {
      vda = {
        volume = "burner.qcow2";
        capacity = 16384;
        mountTo = "/";
        fsType = "ext4";
      };
    };
    sharedDirectories = {
      ctf = {
        source = "/home/user/misc/ctf";
        target = "/ctf";
      };
    };
  };

  # allow passwordless login
  users.allowNoPasswordLogin = true;
  users.users.user.initialHashedPassword = "";

  # auto login
  #services.getty.autologinUser = "user";

  # allow passwordless sudo
  security.sudo.wheelNeedsPassword = false;

  # disable firewall
  networking.firewall.enable = false;

  # user-mode qemu
  boot.binfmt.emulatedSystems = [ "armv7l-linux" "aarch64-linux" ];

  # allow unprivileged ptrace
  boot.kernel.sysctl."kernel.yama.ptrace_scope" = 0;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # default
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd

      sqlite

      #LSB
      # Core
      glibc
      gcc.cc
      zlib
      ncurses5
      ncurses6
      linux-pam
      nspr
      nspr
      nss
      openssl

      # Runtime Languages
      libxml2
      libxslt

      # Bonus (not in LSB)
      bzip2
      curl
      expat
      libusb1
      libcap
      dbus
      libuuid

      ## Graphics Libraries (X11)
      xorg.libX11
      xorg.libxcb
      xorg.libSM
      xorg.libICE
      xorg.libXt
      xorg.libXft
      xorg.libXrender
      xorg.libXext
      xorg.libXi
      xorg.libXtst
      xorg.libXcursor
      xorg.libXcomposite
      xorg.libXfixes
      xorg.libXdamage
      xorg.libXrandr
      xorg.libXScrnSaver
      xorg.libXfixes
      libxkbcommon

      ## OpenGL Libraries
      libGL
      libGLU

      ## Misc. desktop
      libpng12
      libjpeg
      fontconfig
      freetype
      libtiff
      cairo
      pango
      atk

      ## GTK+ Stack Libraries
      # gtk2
      gtk3
      gdk-pixbuf
      glib
      dbus-glib
      at-spi2-core
      at-spi2-atk

      ## Qt Libraries
      #qt4
      # qt5.full

      ## Sound libraries
      alsaLib
      openal

      ## SDL
      SDL
      SDL_image
      SDL_mixer
      SDL_ttf
      SDL2
      SDL2_image
      SDL2_mixer
      SDL2_ttf

      # Imaging
      cups
      sane-backends

      # Trial Use
      libpng
      # gtk3

      libslirp
      libselinux
      pixman
    ];
  };

  home-manager.users.user = {
    imports = with self.homeManagerModules; [
      hacking
    ];
  };

  # slow
  documentation.nixos.enable = false;

  environment.systemPackages = with pkgs; [
    xpra
    (pkgs.buildFHSEnv {
      name = "fhs-env";
      unshareUser = false;
      unshareIpc = false;
      unsharePid = false;
      unshareUts = false;
      unshareCgroup = false;
      targetPkgs = pkgs: (with pkgs; [
        ncurses.dev

        # default
        zlib
        zstd
        stdenv.cc.cc
        curl
        openssl
        attr
        libssh
        bzip2
        libxml2
        acl
        libsodium
        util-linux
        xz
        systemd

        sqlite

        #LSB
        # Core
        glibc
        gcc.cc
        zlib
        ncurses5
        ncurses6
        linux-pam
        nspr
        nspr
        nss
        openssl

        # Runtime Languages
        libxml2
        libxslt

        # Bonus (not in LSB)
        bzip2
        curl
        expat
        libusb1
        libcap
        dbus
        libuuid

        ## Graphics Libraries (X11)
        xorg.libX11
        xorg.libxcb
        xorg.libSM
        xorg.libICE
        xorg.libXt
        xorg.libXft
        xorg.libXrender
        xorg.libXext
        xorg.libXi
        xorg.libXtst
        xorg.libXcursor
        xorg.libXcomposite
        xorg.libXfixes
        xorg.libXdamage
        xorg.libXrandr
        xorg.libXScrnSaver
        xorg.libXfixes
        libxkbcommon

        ## OpenGL Libraries
        libGL
        libGLU

        ## Misc. desktop
        libpng12
        libjpeg
        fontconfig
        freetype
        libtiff
        cairo
        pango
        atk

        ## GTK+ Stack Libraries
        # gtk2
        gtk3
        gdk-pixbuf
        glib
        dbus-glib
        at-spi2-core
        at-spi2-atk

        ## Qt Libraries
        #qt4
        # qt5.full

        ## Sound libraries
        alsaLib
        openal

        ## SDL
        SDL
        SDL_image
        SDL_mixer
        SDL_ttf
        SDL2
        SDL2_image
        SDL2_mixer
        SDL2_ttf

        # Imaging
        cups
        sane-backends

        # Trial Use
        libpng
        # gtk3

        gdb
        libslirp
        libselinux
        pixman
      ]);
      multiPkgs = pkgs: (with pkgs; [
        # default
        zlib
        zstd
        stdenv.cc.cc
        curl
        openssl
        attr
        libssh
        bzip2
        libxml2
        acl
        libsodium
        util-linux
        xz
        systemd

        sqlite

        #LSB
        # Core
        glibc
        gcc.cc
        zlib
        ncurses5
        ncurses6
        linux-pam
        nspr
        nspr
        nss
        openssl

        # Runtime Languages
        libxml2
        libxslt

        # Bonus (not in LSB)
        bzip2
        curl
        expat
        libusb1
        libcap
        dbus
        libuuid

        ## Graphics Libraries (X11)
        xorg.libX11
        xorg.libxcb
        xorg.libSM
        xorg.libICE
        xorg.libXt
        xorg.libXft
        xorg.libXrender
        xorg.libXext
        xorg.libXi
        xorg.libXtst
        xorg.libXcursor
        xorg.libXcomposite
        xorg.libXfixes
        xorg.libXdamage
        xorg.libXrandr
        xorg.libXScrnSaver
        xorg.libXfixes
        libxkbcommon

        ## OpenGL Libraries
        libGL
        libGLU

        ## Misc. desktop
        libpng12
        libjpeg
        fontconfig
        freetype
        libtiff
        cairo
        pango
        atk

        ## GTK+ Stack Libraries
        # gtk2
        gtk3
        gdk-pixbuf
        glib
        dbus-glib
        at-spi2-core
        at-spi2-atk

        ## Qt Libraries
        #qt4
        #qt5

        ## Sound libraries
        alsaLib
        openal

        ## SDL
        SDL
        SDL_image
        SDL_mixer
        SDL_ttf
        SDL2
        SDL2_image
        SDL2_mixer
        SDL2_ttf

        # Imaging
        cups
        sane-backends

        # Trial Use
        libpng
        libselinux
        # gtk3
        pixman
      ]);
      runScript = "zsh";
    })

    #LSB
    # Core
    bc
    gnum4
    man
    lsb-release
    file
    psmisc
    ed
    gettext
    utillinux

    # Languages
    #python2
    perl
    #python3

    # Misc.
    pciutils
    which
    usbutils

    # Bonus
    bzip2

    # Desktop
    xdg_utils
    xorg.xrandr
    fontconfig
    cups

    # Imaging
    foomatic-filters
    ghostscript

    gnumake
    bsdgames
    libreoffice
  ];

  hardware.opengl.enable = lib.mkDefault true;
  hardware.opengl.driSupport32Bit = lib.mkDefault true;

  fonts = {
    packages = with pkgs; [
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
      ngkz.sarasa-term-j-nerd-font
    ];

    # Create a directory with links to all fonts in /run/current-system/sw/share/X11/fonts
    fontDir.enable = true;

    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Noto Sans CJK JP" ];
        serif = [ "Noto Serif CJK JP" ];
        emoji = [ "Blobmoji" ];
        monospace = [ "Sarasa Term J Nerd Font" ];
      };
      cache32Bit = true;
      # XXX Workaround for nixpkgs#46323
      localConf = builtins.readFile "${pkgs.ngkz.blobmoji-fontconfig}/etc/fonts/conf.d/75-blobmoji.conf";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
