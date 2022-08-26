{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.44.0";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "1y1ajr0x0f9r6bbgajvm2mrq0yrdppwvg88acgmpxfnj0vi4z69n";
  };
}
