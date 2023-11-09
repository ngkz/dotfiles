{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.53.2";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "02251dnp69zrrlbijqjyl8rfgaymq6mha513bzbgkzsv641yl3rk";
  };
}
