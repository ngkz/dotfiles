{ buildPythonPackage, fetchFromGitHub, scikit-build, cmake, ninja, swig }:
buildPythonPackage rec {
  pname = "py-slvs";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "realthunder";
    repo = "slvs_py";
    rev = "846e8c94e703ce52161b083abc724dc84d641bd4";
    hash = "sha256-/eYfzvU9zBtWyEkdi8Hux+rwo/MZ8vY/fJ3EdEdl7iY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    scikit-build
    swig
  ];
  dontUseCmakeConfigure = true;

  pythonImportsCheck = [ "py_slvs" ];
  doCheck = false;
}
