{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.54.0";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "0q6y4vwsfx9zkgdv0sd9jxyns59xb8vq66bmnb2kdnf7w0wxsk38";
  };
}
