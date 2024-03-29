{ lib
, symlinkJoin
, makeWrapper
, fcitx5
, fcitx5-lua
, fcitx5-configtool
, fcitx5-qt
, fcitx5-gtk
, coreutils
, which
, gnugrep
, kdialog
, gettext
, dbus
, xprop
, xdg-utils
, systemsettings
, addons ? [ ]
, kcmSupport ? true
}:

symlinkJoin {
  name = "fcitx5-with-addons-${fcitx5.version}";

  paths = [ fcitx5 fcitx5-configtool fcitx5-lua fcitx5-qt fcitx5-gtk ] ++ addons;

  nativeBuildInputs = [ makeWrapper ];

  postBuild =
    let
      configtool-path = lib.makeBinPath (
        [ coreutils which gnugrep kdialog gettext dbus xprop fcitx5-configtool xdg-utils ] ++
        lib.optionals kcmSupport [ systemsettings ]
      );
    in
    ''
      # fcitx5 starts ''${fcitx5}/bin/fcitx5-configtool instead of the tool in the $PATH
      wrapProgram $out/bin/fcitx5 \
        --prefix FCITX_ADDON_DIRS : "$out/lib/fcitx5" \
        --suffix XDG_DATA_DIRS : "$out/share" \
        --suffix PATH : "$out/bin:${configtool-path}"

      wrapProgram $out/bin/fcitx5-configtool --prefix PATH ":" "${configtool-path}"

      desktop=share/applications/org.fcitx.Fcitx5.desktop
      autostart=etc/xdg/autostart/org.fcitx.Fcitx5.desktop
      rm $out/$desktop
      rm $out/$autostart
      cp ${fcitx5}/$desktop $out/$desktop
      sed -i $out/$desktop -e "s|^Exec=.*|Exec=$out/bin/fcitx5|g"
      ln -s $out/$desktop $out/$autostart
    '';

  meta = fcitx5.meta;
}
