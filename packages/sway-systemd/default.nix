{ lib
, stdenv
, fetchFromGitHub
, systemd
, meson
, ninja
, pkg-config
, dbus
, sway
, dbus-next
, i3ipc
, psutil
, tenacity
, xlib
, makeWrapper
, python3
, wrapPython
, ...
}:

stdenv.mkDerivation rec {
  pname = "sway-systemd";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "alebastr";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-AJ87/sPy8IVJgb5YehfUfNTOFEDithLfiTxgZfZf238=";
  };

  PKG_CONFIG_SYSTEMD_SYSTEMDUSERUNITDIR = "${placeholder "out"}/lib/systemd/user";

  pythonPath = [
    dbus-next
    i3ipc
    tenacity
    psutil
    xlib
  ];

  buildInputs = [
    systemd
    python3
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    makeWrapper
    wrapPython
  ];

  postInstall = ''
    patchShebangs $out/libexec/sway-systemd/*
    wrapProgram $out/libexec/sway-systemd/session.sh --prefix PATH : ${lib.makeBinPath [ systemd dbus sway ]}
    wrapPythonProgramsIn $out/libexec/sway-systemd "$pythonPath"
  '';
}
