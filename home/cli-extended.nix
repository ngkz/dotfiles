{ pkgs, ... }:

{
  home.enableDebugInfo = true;

  home.packages = with pkgs; [
    binutils
    gdb
    gcc
    strace
    ltrace
    picocom
    ffmpeg
    hugo
    sqlite
    geteltorito
    sbsigntool
    ngkz.scripts
    dislocker
    ansible
    exiftool
    jpegoptim
    optipng
    imagemagick
    bsdgames
    yt-dlp
    mp3gain
    aacgain
    mprime
    qrencode
    ijq #interactiv jq
    dos2unix
    wireguard-tools
    nix-output-monitor
  ];
}
