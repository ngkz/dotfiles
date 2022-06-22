{ callPackage, fetchFromGitHub, ngkz, lib, nodejs, ... }:
let
  nodeDependencies = (callPackage ./node.nix { }).nodeDependencies;
in
ngkz.buildChromiumExtension rec {
  pname = "mouse-dictionary";
  version = "1.6.3";
  src = fetchFromGitHub {
    owner = "wtetsu";
    repo = "mouse-dictionary";
    rev = "v${version}";
    sha256 = "zmsOkyN9Z1DoOLw+g9rOVNeUiGYZhEnJAq4pxgMJv7Q=";
  };
  buildInputs = [ nodejs ];
  buildPhase = ''
    ln -s ${nodeDependencies}/lib/node_modules ./node_modules
    export PATH="${nodeDependencies}/bin:$PATH"

    npm run release-chrome
    cd dist-chrome
  '';
}
