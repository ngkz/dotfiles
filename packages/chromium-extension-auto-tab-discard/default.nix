{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "auto-tab-discard";
  version = "0.6.3";
  src = fetchzip {
    url = "https://github.com/rNeomy/auto-tab-discard/archive/refs/tags/${version}.zip";
    sha256 = "1ppvxha4l2vivv9v44sy4lhw53xy4kr66f97sg2ncnpig4181jgg";
  };
  sourceRoot = "source/v3";
}
