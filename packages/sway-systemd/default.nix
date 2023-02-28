{ lib
, stdenv
, fetchFromGitHub
, systemd
, meson
, ninja
, pkgconfig
, dbus
, sway
, dbus-next
, i3ipc
, psutil
, tenacity
, xlib
, makeWrapper
, wrapPython
, cgroups ? false
, autostart ? false
, locale1 ? false
, ...
}:

stdenv.mkDerivation rec {
  pname = "sway-systemd";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "alebastr";
    repo = pname;
    rev = "v${version}";
    sha256 = "Azy7XRHrKvhODxAogwtk2+W0WjGcoTy47+nT0x9aMPw=";
  };

  patches = [
    ./stop-graphical-session.patch
  ];

  mesonFlags = lib.optionals cgroups [
    "-Dcgroups=enabled"
  ] ++ lib.optionals autostart [
    "-Dautostart=true"
  ] ++ lib.optionals locale1 [
    "-Dlocale1=true"
  ];

  PKG_CONFIG_SYSTEMD_SYSTEMDUSERUNITDIR = "${placeholder "out"}/lib/systemd/user";

  pythonPath = [
    dbus-next
  ] ++ lib.optionals (cgroups || locale1) [
    i3ipc
  ] ++ lib.optionals (cgroups || autostart) [
    tenacity
  ] ++ lib.optionals cgroups [
    psutil
    xlib
  ];

  buildInputs = [
    systemd
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkgconfig
    makeWrapper
    wrapPython
  ];

  postInstall = ''
    wrapProgram $out/libexec/sway-systemd/session.sh --prefix PATH : ${lib.makeBinPath [ systemd dbus sway ]}
    wrapPythonProgramsIn $out/libexec/sway-systemd "$pythonPath"
  '';
}
