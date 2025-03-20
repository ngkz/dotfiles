{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.63.2";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "11261qnr91cli40k1wig964l08dkqkl6vnfg6iw36s6g6bms6iz0";
  };
}
