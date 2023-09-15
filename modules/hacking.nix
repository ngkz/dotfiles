{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; with linuxPackages; [
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
    ropgadget
    hashcat
    hashcat-utils
    # hcxtools
    thc-hydra
    aircrack-ng
    tesseract4
    nasm
    gcc
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

    ghidra
    burpsuite
  ];

  modules.base.pythonPackages = p: with p; [
    pwntools
    angr
    z3
    capstone
    cryptography
    scapy
  ];

  programs.wireshark.enable = true;
}
