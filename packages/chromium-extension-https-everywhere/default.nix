{ pkgs, lib, ... }:
let
  inherit (pkgs.my) buildChromiumExtension;
  inherit (pkgs) fetchFromGitHub;
in
buildChromiumExtension rec {
  pname = "https-everywhere";
  version = "2021.7.13";
  src = fetchFromGitHub {
    owner = "EFForg";
    repo = "https-everywhere";
    rev = version;
    fetchSubmodules = true;
    sha256 = "GzHk2QUdQ/kfYlPzOwzCElw5tVuc/FiLmkFVoMlZTNM=";
  };
  buildInputs = with pkgs; [ bash getopt python3 ];
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
