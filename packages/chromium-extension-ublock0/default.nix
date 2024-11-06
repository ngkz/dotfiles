{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.61.0";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "098gnvxn6z8yiww5xkci7wp6ldsjr25lzdv63lwxd07jdv53andp";
  };
}
