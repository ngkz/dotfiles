{ pkgs, lib, ... }:
let
  inherit (pkgs.my) buildChromiumExtension;
  inherit (pkgs) fetchFromGitHub fetchYarnDeps fixup_yarn_lock yarn;

  src_sha256 = "D3BUIvB0i8piUUMEMiueE64ARezIwUNXy+19sqv/yR8=";
  yarn_sha256 = "1ra9g9ysxyv8phgxazpij2pj5nkinp5rarb75wnsapxm2b89z0am";
in
buildChromiumExtension rec {
  pname = "vue-devtools";
  version = "6.1.4";

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

  buildInputs = with pkgs; [ fixup_yarn_lock yarn nodejs ];

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
