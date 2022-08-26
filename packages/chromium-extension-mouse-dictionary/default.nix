{ callPackage, fetchFromGitHub, ngkz, lib, nodejs, ... }:
let
  nodeDependencies = (callPackage ./node.nix { }).nodeDependencies;
in
ngkz.buildChromiumExtension rec {
  pname = "mouse-dictionary";
  version = "1.6.4";
  src = fetchFromGitHub {
    owner = "wtetsu";
    repo = "mouse-dictionary";
    rev = "v${version}";
    sha256 = "ImUXyPTSZ7LdkumzGOv2AvAI3twbhiav1O7f7ZQD9Es=";
  };
  buildInputs = [ nodejs ];
  buildPhase = ''
    ln -s ${nodeDependencies}/lib/node_modules ./node_modules
    export PATH="${nodeDependencies}/bin:$PATH"

    npm run release-chrome
    cd dist-chrome
  '';
}
