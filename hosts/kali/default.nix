{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "vagrant";
  home.homeDirectory = "/home/vagrant";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    # gdb
    # pwndbg
    # strace
    # ltrace
    # netcat-openbsd
    # # radare2
    # # radare2-cutter
    # pwntools
    # python3Packages.binwalk-full
    # foremost
    # nkf
    # qemu_full
    # metasploit
    # nmap
    # z3
    # aflplusplus
    # apktool
    # dex2jar
    # enjarify
    # jd-gui
    # sqlmap
    # linux-exploit-suggester
    # john
    # #volatility #XXX broken
    # ghdorker
    # uefitool
    # #pkgs.python38Packages.uncompyle6 #XXX broken
    # xortool
    # ropgadget
    # hashcat
    # hashcat-utils
    # # hcxtools
    # thc-hydra
    # aircrack-ng
    # tesseract4
    # nasm
    # patchelf
    # pngtools
    # zbar
    # php
    # nodejs
    # deno
    # socat
    # dtc
    # qtspim
    # sqlite
    # subversion
    # git
    # systemtap
    # p7zip
    # # p0f
    # pdf-parser
    # mitmproxy
    # termshark
    # ares-rs
    # badchars
    # jwt-cli
    # snscrape
    # gobuster # /usr/share/wordlists/dirbuster/directory-list-2.3-medium.tx
    # # dnsmap
    # # dnsrecon
    # python3Packages.pypykatz
    # oletools
    # # stegsnow
    # # flask-unsign
    # wabt
    # one_gadget

    # ghidra
    # burpsuite
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/vagrant/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  imports = [
    ../../home/base
    ../../home/hacking
  ];
}
