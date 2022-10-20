{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "auto-tab-discard";
  version = "0.6.4";
  src = fetchzip {
    url = "https://github.com/rNeomy/auto-tab-discard/archive/refs/tags/${version}.zip";
    sha256 = "155qi3cnwnb4ii915ppvxzdcfd1kmfh1whzs5i85rzhvdzmmfmv8";
  };
  sourceRoot = "source/v3";
}
