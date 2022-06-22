{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "reddit-enhancement-suite";
  version = "5.22.10";
  src = fetchzip {
    url = "https://github.com/honestbleeps/Reddit-Enhancement-Suite/releases/download/v${version}/chrome.zip";
    sha256 = "03zmm9b38362mg8m7d9y45r5254dbfss0v19fdcj756nfml3in1f";
    stripRoot = false;
  };
}
