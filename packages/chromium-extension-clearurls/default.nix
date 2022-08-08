{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "clearurls";
  version = "1.25.0";
  src = fetchzip {
    url = "https://github.com/ClearURLs/Addon/releases/download/${version}/ClearURLs-${version}-chrome.zip";
    sha256 = "011rywxfijigpigv9sjnzdbk321bqpxy3pib2qm88izv9arxfy30";
    stripRoot = false;
  };
}
