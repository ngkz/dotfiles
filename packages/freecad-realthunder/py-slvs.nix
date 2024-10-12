{ buildPythonPackage, fetchFromGitHub, scikit-build, cmake, ninja, swig }:
buildPythonPackage rec {
  pname = "py-slvs";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "realthunder";
    repo = "slvs_py";
    rev = "8bacae911c0c94c04ec8219aad3548b3b54f886e";
    hash = "sha256-b9DgsQ+lJ430WYjMUreCOAhTAZt1lFVMwItdY4/alk4=";
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
