{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.45.0";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "144gkdjj1qah3x4v2z4c1ibj7nsldghh47acpmagn2j9ymmfc70r";
  };
}
