{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "auto-tab-discard";
  version = "0.6.3.2";
  src = fetchzip {
    url = "https://github.com/rNeomy/auto-tab-discard/archive/refs/tags/${version}.zip";
    sha256 = "0z301z8vxq9ica6z4nmi5bffan8bxv6668f5fs7vrb5x5h0s5j1i";
  };
  sourceRoot = "source/v3";
}
