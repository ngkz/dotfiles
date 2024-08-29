# hacking: install hacking tools
{ pkgs, ... }:
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
    radare2
    iaito
    python3Packages.binwalk-full
    foremost
    nkf
    qemu_full
    metasploit
    nmap
    rustscan
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
    mono
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

    ghidra
    burpsuite
    rehex
    xclip
  ];

  cli-essential.pythonPackages = p: with p; [
    pwntools
    angr
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
