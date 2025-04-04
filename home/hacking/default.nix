# hacking: install hacking tools
{ pkgs, lib, ... }:
{
  imports = [
    ../tmpfs-as-home.nix
  ];

  xdg.enable = true;

  tmpfs-as-home.persistentDirs = [
    ".ghidra"
  ];

  home.packages = with pkgs; with linuxPackages; [
    gdb
    pwndbg
    strace
    ltrace
    netcat-openbsd
    unstable.binwalk
    foremost
    nkf
    qemu_full
    metasploit
    nmap
    rustscan
    aflplusplus
    aapt
    apktool
    dex2jar
    enjarify
    jadx
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
    gobuster
    ffuf
    # dnsmap
    dnsrecon
    python3Packages.pypykatz
    oletools
    # stegsnow
    # flask-unsign
    wabt
    one_gadget
    upx
    (lib.hiPrio mono)
    pkgsCross.mingwW64.buildPackages.gcc
    proxychains
    chisel
    krb5
    responder
    powershell
    dive
    exiftool
    geteltorito
    dislocker
    can-utils
    python3Packages.cantools
    linux-wifi-hotspot
    erofs-utils
    apksigner
    docker-compose
    awscli2
    python3Packages.wsgidav

    (ghidra.withExtensions (p: [ ngkz.avr-ghidra-helpers ]))
    burpsuite
    rehex
    xclip
    savvycan
    testdisk-qt
  ];

  cli-essential.pythonPackages = p: with p; [
    pwntools
    # angr # XXX broken
    z3
    capstone
    cryptography
    scapy
    requests
    httpx
    impacket

    flask
    treelib
    scp

  ];

  xdg.configFile."gdb/gdbinit".source = ./gdbinit;
  programs.zsh.localVariables.SECLISTS = "${pkgs.seclists}/share/wordlists/seclists";
}
