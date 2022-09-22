{ lib
, fetchFromGitHub
, python
, buildPythonApplication
, cffi
, cryptography
, protobuf
, pycparser
, six
}:
buildPythonApplication rec {
  pname = "crx3-creator";
  version = "unstable-2022-02-11";

  propagatedBuildInputs = [ cffi cryptography protobuf pycparser six ];

  src = fetchFromGitHub {
    owner = "pawliczka";
    repo = "CRX3-Creator";
    rev = "6aa7d583dc28b2845cd59b14c3ac3e2041aa5379";
    sha256 = "fp4S+Vb8Mun2dF2wqM2OhbzRSnJ1z0I3vlIZBVjnYGg=";
  };

  format = "other";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    echo "#!/usr/bin/python3" >$out/bin/${pname}
    cat $src/main.py >>$out/bin/${pname}
    chmod 755 $out/bin/${pname}

    install -vD $src/crx3_pb2.py $out/${python.sitePackages}/crx3_pb2.py

    runHook postInstall
  '';
}
