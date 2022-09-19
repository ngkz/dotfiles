{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublacklist";
  version = "8.0.2";
  src = fetchzip {
    url = "https://github.com/iorate/ublacklist/releases/download/v${version}/ublacklist-v${version}-chrome-mv3.zip";
    sha256 = "07gx85bkhgv89x1sl7ribhdrc6hqlvwq6p5h1nhrx422cspg0i1g";
    stripRoot = false;
  };
}
