{ stdenv, openssh, pkg-config, gtk3 }:

stdenv.mkDerivation rec {
  pname = "gnome-ssh-askpass3";

  inherit (openssh) version src patches postPatch;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ gtk3 ];

  buildPhase = ''
    cd contrib
    make ${pname}
  '';

  dontConfigure = true;

  installPhase = ''
    install -Dm755 ${pname} $out/libexec/${pname}
  '';
}
