{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.49.0";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "1n6gk5i8nn4ivp9vm1qn05ahqyw72v3sy6x8mwzgn5n3mpacq4jp";
  };
}
