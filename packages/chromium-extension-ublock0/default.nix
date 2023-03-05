{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.47.4";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "15ya9g2fbcixvb3c5gk16gcvvrykdgcpz3mr4021379ahp30y5xx";
  };
}
