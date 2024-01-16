# hacking: install hacking tools
{ config, lib, pkgs, ... }:
{
  imports = [
    ../tmpfs-as-home.nix
  ];

  xdg.enable = true;

  tmpfs-as-home.persistentDirs = [
    ".ghidra"
  ];

  home.packages = with pkgs; with linuxPackages; [
    binutils
    gdb
    pwndbg
    strace
    ltrace
    netcat-openbsd
    radare2
    radare2-cutter
    python3Packages.binwalk-full
    foremost
    nkf
    qemu_full
    metasploit
    nmap
    z3
    aflplusplus
    apktool
    dex2jar
    enjarify
    jd-gui
    sqlmap
    linux-exploit-suggester
    john
    #volatility #XXX broken
    ghdorker
    uefitool
    #pkgs.python38Packages.uncompyle6 #XXX broken
    xortool
    #ropgadget #pwntools in python environment brings ROPgadget in
    hashcat
    hashcat-utils
    # hcxtools
    thc-hydra
    aircrack-ng
    tesseract4
    nasm
    patchelf
    pngtools
    zbar
    php
    nodejs
    deno
    socat
    dtc
    qtspim
    sqlite
    subversion
    git
    systemtap
    p7zip
    # p0f
    pdf-parser
    mitmproxy
    termshark
    ares-rs
    badchars
    jwt-cli
    snscrape
    gobuster # /usr/share/wordlists/dirbuster/directory-list-2.3-medium.tx
    # dnsmap
    # dnsrecon
    python3Packages.pypykatz
    oletools
    # stegsnow
    # flask-unsign
    wabt
    one_gadget

    ghidra
    burpsuite
  ];

  cli-base.pythonPackages = p: with p; [
    pwntools
    angr
    z3
    capstone
    cryptography
    scapy
    requests
    httpx

    flask
  ];

  xdg.configFile."gdb/gdbinit".source = ./gdbinit;
}
