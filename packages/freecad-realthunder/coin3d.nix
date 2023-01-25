{ lib
, stdenv
, fetchFromGitHub
, boost
, cmake
, libGL
, libGLU
, libX11
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "coin-realthunder";
  version = "unstable-2021-09-15";

  src = fetchFromGitHub {
    owner = "realthunder";
    repo = "coin";
    rev = "Coin-20210915";
    sha256 = "uzE5R4tpCl00zz+g1FuQ1c0AZ+3dTFlCHAlyjaEHc9o=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    libGL
    libGLU
    libX11
  ];

  cmakeFlags = [ "-DCOIN_USE_CPACK=OFF" ];

  meta = with lib; {
    homepage = "https://github.com/realthunder/coin.git";
    description = "High-level, retained-mode toolkit for effective 3D graphics development (realthunder's fork)";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
})
