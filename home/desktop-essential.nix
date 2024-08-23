{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wl-clipboard
    xdg-utils
    pulseaudio
    glib.bin #gsettings
    evtest
    libinput.bin #libinput
    libnotify #notify-send
    libsecret # secret-tool
    zbar
  ];
}
