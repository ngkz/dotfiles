{ lib, stdenv, fetchFromGitHub, systemd, meson, ninja, pkgconfig, dbus, sway, makeWrapper, ... }:

stdenv.mkDerivation rec {
  pname = "sway-systemd";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "alebastr";
    repo = pname;
    rev = "v${version}";
    sha256 = "S10x6A1RaD1msIw9pWXpBHFKKyWfsaEGbAZo2SU3CtI=";
  };

  patches = [
    ./stop-graphical-session.patch
  ];

  PKG_CONFIG_SYSTEMD_SYSTEMDUSERUNITDIR = "${placeholder "out"}/lib/systemd/user";

  buildInputs = [
    systemd
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkgconfig
    makeWrapper
  ];

  postInstall = ''
    wrapProgram $out/libexec/sway-systemd/session.sh --prefix PATH : ${lib.makeBinPath [ systemd dbus sway ]}
  '';
}
