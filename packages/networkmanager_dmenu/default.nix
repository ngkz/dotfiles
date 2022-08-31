{ lib
, stdenv
, glib
, fetchFromGitHub
, networkmanager
, python3Packages
, gobject-introspection
, bemenu
, libnotify
, networkmanagerapplet
}:

let
  inherit (python3Packages) python pygobject3;
  release = "2.1.0";
in
stdenv.mkDerivation rec {
  pname = "networkmanager_dmenu";
  version = "${release}.${builtins.substring 0 7 src.rev}";

  src = fetchFromGitHub {
    owner = "firecat53";
    repo = "networkmanager-dmenu";
    rev = "d1ae6273ef8380cb2e8c8133d0ee51e8b6ca86dd";
    sha256 = "LDLGHM+6/IIGAuwiLx1k2vFRt3D2BzLuEjZ7G8PVt9I=";
  };

  buildInputs = [ glib python pygobject3 gobject-introspection networkmanager python3Packages.wrapPython ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/share/applications $out/share/doc/$pname
    cp networkmanager_dmenu $out/bin/
    cp networkmanager_dmenu.desktop $out/share/applications
    cp README.md $out/share/doc/$pname/
    cp config.ini.example $out/share/doc/$pname/
  '';

  # FIXME PATH 🤔
  postFixup = ''
    makeWrapperArgs="\
      --prefix GI_TYPELIB_PATH : $GI_TYPELIB_PATH \
      --prefix PYTHONPATH : \"$(toPythonPath $out):$(toPythonPath ${pygobject3})\"
      --prefix PATH : "${lib.makeBinPath [libnotify networkmanagerapplet bemenu]}"
      "
    wrapPythonPrograms
  '';


  meta = with lib; {
    description = "Small script to manage NetworkManager connections with dmenu instead of nm-applet";
    homepage = "https://github.com/firecat53/networkmanager-dmenu";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jensbin ];
    platforms = lib.platforms.all;
  };
}
