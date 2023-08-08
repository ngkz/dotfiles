{ lib, stdenv, fetchurl
, openssl, readline, ncurses, zlib
, dataDir ? "/var/lib/softether" }:

stdenv.mkDerivation rec {
  pname = "softether";
  version = "4.42";
  build = "9798";

  src = fetchurl {
    url = "https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/archive/refs//tags/v${version}-${build}-rtm.tar.gz";
    sha256 = "13rn8j287ff6mqpacy6c4f10rdj6wsvajphzwlkmzvgf9ap80sak";
  };

  patches = [
    ./remove-region-lock.patch
  ];

  buildInputs = [ openssl readline ncurses zlib ];

  preConfigure = ''
    ./configure
  '';

  buildPhase = ''
    mkdir -p $out/bin
    sed -i \
      -e "/INSTALL_BINDIR=/s|/usr/bin|/bin|g" \
      -e "/_DIR=/s|/usr|${dataDir}|g" \
      -e "s|\$(INSTALL|$out/\$(INSTALL|g" \
      -e "/echo/s|echo $out/|echo |g" \
      Makefile
  '';

  meta = with lib; {
    description = "An Open-Source Free Cross-platform Multi-protocol VPN Program";
    homepage = "https://www.softether.org/";
    license = licenses.asl20;
    maintainers = [ maintainers.rick68 ];
    platforms = [ "x86_64-linux" ];
  };
}
