{ fetchFromGitHub, fetchYarnDeps, fixup_yarn_lock, yarn, nodejs, ngkz, lib, ... }:
let
  src_sha256 = "pBTZoQiqtnhirdXYbxlxVp6anjIrJdGpX3kGkUBoPPU=";
  yarn_sha256 = "04fjf2n35dxx493h47jbn9w7pqyj64rmlabgirl3a6a5glbqkbvy";
in
ngkz.buildChromiumExtension rec {
  pname = "vue-devtools";
  version = "6.3.0";

  src = fetchFromGitHub {
    owner = "vuejs";
    repo = "devtools";
    rev = "v${version}";
    sha256 = src_sha256;
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    sha256 = yarn_sha256;
  };

  buildInputs = [ fixup_yarn_lock yarn nodejs ];

  configurePhase = ''
    chmod u+w . ./yarn.lock
    export HOME=$PWD/../tmp
    mkdir -p $HOME
    yarn config --offline set yarn-offline-mirror ${yarnOfflineCache}
    fixup_yarn_lock yarn.lock
    yarn install --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive
    patchShebangs node_modules/
    node_modules/.bin/lerna bootstrap -- --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive
    patchShebangs node_modules/
  '';

  buildPhase = ''
    npm run build
    cd packages/shell-chrome
  '';
}
