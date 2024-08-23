{ pkgs, ... }:

{
  home.packages = with pkgs; [
    binutils
    gdb
    gcc
    strace
    ltrace
    picocom
    ffmpeg
    manix # nix documentation searcher
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
    #bsdgames # FIXME conflicts with mono
    yt-dlp
    mp3gain
    aacgain
    mprime
    qrencode
  ];
}
