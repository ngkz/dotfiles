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
    rev = "ba1f6b514c0db7632d9288c5624c51856bd90650";
    hash = "sha256-40dGA7Cm//7kas0ds67fKKivUJ2l87lgbU3FW9eHXak=";
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
