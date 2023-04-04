{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.8.6";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "1ag3y50bchxip4krl7fw2abf2qf7vr5f6dbjpcq6jclfr32ddzvi";
    stripRoot = false;
  };
}
