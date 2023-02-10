{ lib
, stdenvNoCC
, bash
, coreutils
, pulseaudio
, libnotify
, gawk
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
, xdg-utils
, gnused
, libcanberra-gtk3
, nwg-launchers
, ...
}:
stdenvNoCC.mkDerivation rec {
  name = "hotkey-scripts";

  preferLocalBuild = true;
  phases = "installPhase";
  inherit bash;

  installPhase = ''
    mkdir -p $out/bin
    substitute ${./volume.sh} $out/bin/volume \
               --subst-var bash \
               --subst-var-by path "${lib.makeBinPath [pulseaudio libnotify gawk libcanberra-gtk3]}"
    substitute ${./micmute.sh} $out/bin/micmute \
               --subst-var bash \
               --subst-var-by path "${lib.makeBinPath [pulseaudio libnotify gawk]}"
    substitute ${./brightness.sh} $out/bin/brightness \
               --subst-var bash \
               --subst-var-by path "${lib.makeBinPath [light libnotify coreutils]}"
    substitute ${./powermenu.sh} $out/bin/powermenu \
               --subst-var bash \
               --subst-var-by path "${lib.makeBinPath [nwg-launchers systemd sway]}" \
               --subst-var-by template-desktop ${./powermenu-desktop.json} \
               --subst-var-by template-greeter  ${./powermenu-greeter.json}
    substitute ${./screenshot.sh} $out/bin/screenshot \
               --subst-var bash \
               --subst-var-by path "${lib.makeBinPath [wofi coreutils grim slurp wl-clipboard
                                                       xdg-user-dirs swappy sway jq libnotify
                                                       xdg-utils]}"
    substitute ${./switch-window.sh} $out/bin/switch-window \
               --subst-var bash \
               --subst-var-by path "${lib.makeBinPath [wofi sway jq gnused]}"
    substitute ${./multihead.sh} $out/bin/multihead \
               --subst-var bash \
               --subst-var-by path "${lib.makeBinPath [jq sway]}"
    substitute ${./workspace.sh} $out/bin/workspace \
               --subst-var bash \
               --subst-var-by path "${lib.makeBinPath [coreutils jq sway gnused]}"
    chmod a+x $out/bin/*
  '';
}
