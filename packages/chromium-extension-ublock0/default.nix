{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.44.4";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "0lslw5sq8s7m09l7wk45pnp7pr3hzl3dq7nbg5mmbpjddbjsm79p";
  };
}
