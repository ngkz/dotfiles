{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublacklist";
  version = "8.0.1";
  src = fetchzip {
    url = "https://github.com/iorate/ublacklist/releases/download/v${version}/ublacklist-v${version}-chrome-mv3.zip";
    sha256 = "1jb3qrr6fs3h3vd4ksf3g2ig2qc8l9qlwrqrssg054l3v85rw5jb";
    stripRoot = false;
  };
}
