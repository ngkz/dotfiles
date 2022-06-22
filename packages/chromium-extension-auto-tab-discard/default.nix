{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "auto-tab-discard";
  version = "0.6.1";
  src = fetchzip {
    url = "https://github.com/rNeomy/auto-tab-discard/archive/refs/tags/v${version}.zip";
    sha256 = "1x3jym7p48hwljwycvpj47l1wa07rn1wd5vg3s43l6nfcwl6803f";
  };
  sourceRoot = "source/v3";
}
