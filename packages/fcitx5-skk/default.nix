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
  version = "5.0.15";

  src = fetchFromGitHub {
    owner = "fcitx";
    repo = pname;
    rev = version;
    sha256 = "y5GciWJMEFQM8SsqYANXe/SdVq6GEqsfF1yrKKhw0KA=";
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
