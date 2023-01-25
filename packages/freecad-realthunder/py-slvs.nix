{ buildPythonPackage, fetchFromGitHub, scikit-build, cmake, ninja, swig }:
buildPythonPackage rec {
  pname = "py-slvs";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "realthunder";
    repo = "slvs_py";
    rev = "c94979b0204a63f26683c45ede1136a2a99cb365";
    sha256 = "bOdTmSMAA0QIRlcIQHkrnDH2jGjGJqs2i5Xaxu2STMU=";
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
