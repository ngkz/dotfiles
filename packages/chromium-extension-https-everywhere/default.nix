{ fetchFromGitHub, ngkz, lib, bash, getopt, python3, ... }:
ngkz.buildChromiumExtension rec {
  pname = "https-everywhere";
  version = "2022.5.24";
  src = fetchFromGitHub {
    owner = "EFForg";
    repo = "https-everywhere";
    rev = version;
    fetchSubmodules = true;
    sha256 = "zjtYSN8LLHbSpDTcQF7Dr5UrpygD7hS+8yp/DafcI1k=";
  };
  buildInputs = [ bash getopt python3 ];
  patchPhase = ''
    # Skip building unneeded artifacts which would require further dependencies or patching.
    sed -i '/$BROWSER/d; /$crx_cws/d; /$crx_eff/d; /$zip/d' ./make.sh
  '';
  buildPhase = ''
    export HOME=$(mktemp -d)
    bash -e -o pipefail ./make.sh
  '';
  preInstall = ''
    cd pkg/crx-eff
  '';
}
