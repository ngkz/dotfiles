{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; with linuxPackages; [
    binutils
    gdb
    pwndbg
    strace
    ltrace
    netcat-openbsd
    radare2
    radare2-cutter
    pwntools
    python3Packages.binwalk-full
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
    ropgadget
    hashcat
    hashcat-utils
    # hcxtools
    # thc-hydra
    aircrack-ng
    tesseract4
    nasm
    pngtools
    zbar
    php
    nodejs
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
    # gobuster
    # dnsmap
    # dnsrecon

    ghidra
    burpsuite

  ];

  home.tmpfs-as-home.persistentDirs = [
    ".ghidra"
  ];

  xdg.configFile."gdb/gdbinit".source = ./gdbinit;
}
