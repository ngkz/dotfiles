{ fetchFromGitHub, fetchYarnDeps, fixup_yarn_lock, yarn, nodejs, ngkz, lib, ... }:
let
  src_sha256 = "0udaT0ywYUs6GVt1TsM8oJbIivzzJpt0UGJF+Rw7kpE=";
  yarn_sha256 = "1jmmwkm6nvpj537v60nmz9dclzyqf04f53vhgsn13hw12csvr0ln";
in
ngkz.buildChromiumExtension rec {
  pname = "vue-devtools";
  version = "6.4.2";

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
