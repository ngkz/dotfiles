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
  pname = "coin3d-realthunder";
  version = "unstable-2023-07-29";

  src = fetchFromGitHub {
    owner = "realthunder";
    repo = "coin";
    rev = "a22c0e32f02b5c6e67ac247c33d9f151682bcb80";
    hash = "sha256-IcY0njvbmTyGlMWekpaTUxvagUR9cBvqpaIw+79KmR4=";
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
