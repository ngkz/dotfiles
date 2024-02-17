{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.56.0";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "1c01adw7s1lxxw6lnzyf3vznw5llzmlf4w5lydnbr9pnaiz9wj8h";
  };
}
