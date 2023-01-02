{ stdenvNoCC
, bash
, coreutils
, pulseaudio
, libnotify
, gawk
, sound-theme-freedesktop
, jq
, light
, wofi
, systemd
, sway
, grim
, slurp
, wl-clipboard
, xdg-user-dirs
, swappy
, imv
, gnused
, ...
}:
stdenvNoCC.mkDerivation rec {
  name = "hotkey-scripts";

  preferLocalBuild = true;
  phases = "installPhase";
  inherit bash coreutils pulseaudio libnotify gawk jq light wofi systemd sway grim;
  inherit gnused slurp swappy imv;
  soundThemeFreedesktop = sound-theme-freedesktop;
  wlClipboard = wl-clipboard;
  xdgUserDirs = xdg-user-dirs;

  installPhase = ''
    mkdir -p $out/bin
    substituteAll ${./volume.sh} $out/bin/volume
    substituteAll ${./micmute.sh} $out/bin/micmute
    substituteAll ${./brightness.sh} $out/bin/brightness
    substituteAll ${./powermenu.sh} $out/bin/powermenu
    substituteAll ${./screenshot.sh} $out/bin/screenshot
    substituteAll ${./switch-window.sh} $out/bin/switch-window
    substituteAll ${./multihead.sh} $out/bin/multihead
    substituteAll ${./workspace.sh} $out/bin/workspace
    chmod a+x $out/bin/*
  '';
}
