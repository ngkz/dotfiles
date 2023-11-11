{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.53.4";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "03nv87qm3lrb7jsclrs6qpmlbwbx6aa2bk27ygh58zc4mkfdabhj";
  };
}
