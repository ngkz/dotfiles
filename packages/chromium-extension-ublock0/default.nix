{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.61.2";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "1qxin0vswdxf9rkx8wavg9ijkfydiiy6v5h2k4m6flxl467jacxb";
  };
}
