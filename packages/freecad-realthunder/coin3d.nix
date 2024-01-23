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
    rev = "3cbbd20cbce672367901dca86275491e59614d04";
    hash = "sha256-ocTfB+4XFe/C0GA0qOk5HPZgOnLC6k8oyr/RqHgCHLU=";
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
