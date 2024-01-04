{ lib
, stdenv
, fetchFromGitHub

, cmake
, wrapQtAppsHook
, extra-cmake-modules
, gettext
, pkg-config

, fcitx5
, fcitx5-qt
, libskk
, skk-dicts
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "fcitx5-skk";
  version = "5.1.1";

  src = fetchFromGitHub {
    owner = "fcitx";
    repo = pname;
    rev = version;
    hash = "sha256-a+ZsuFEan61U0oOuhrTFoK5J4Vd0jj463jQ8Mk7TdbA=";
  };

  cmakeFlags = [
    "-DSKK_DEFAULT_PATH=${ skk-dicts }/share/SKK-JISYO.combined"
  ];

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
    extra-cmake-modules
    gettext
    pkg-config
  ];

  buildInputs = [
    libskk
    fcitx5
    fcitx5-qt
    qtbase
  ];

  meta = with lib; {
    description = "fcitx5-skk is an input method engine for Fcitx5, which uses libskk as its backend.";
    homepage = "https://github.com/fcitx/fcitx5-skk";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
