{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "auto-tab-discard";
  version = "0.6.2";
  src = fetchzip {
    url = "https://github.com/rNeomy/auto-tab-discard/archive/refs/tags/${version}.zip";
    sha256 = "1qk8cxli9fp0bagyjk92c91bjs7zymx87r47myl603h3c274zsl9";
  };
  sourceRoot = "source/v3";
}
