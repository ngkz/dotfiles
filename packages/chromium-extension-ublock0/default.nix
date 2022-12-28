{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.46.0";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "1fzbw8c0x1v2xxgkl46xc41x2n6nv3130ilh3l6y67mh2scvqh7b";
  };
}
