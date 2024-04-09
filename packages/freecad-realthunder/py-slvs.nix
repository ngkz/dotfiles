{ buildPythonPackage, fetchFromGitHub, scikit-build, cmake, ninja, swig }:
buildPythonPackage rec {
  pname = "py-slvs";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "realthunder";
    repo = "slvs_py";
    rev = "b70471944aef07a9a23402f6831f463d031d0ab1";
    hash = "sha256-L7dnQ1cyCeRvXcXuh8e8OPRET3WpsMnkb5yDLYTISc4=";
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
