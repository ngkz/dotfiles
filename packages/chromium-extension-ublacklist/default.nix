{ pkgs, lib, ... }:
let
  inherit (pkgs.ngkz) buildChromiumExtension;
  inherit (pkgs) fetchzip;
in
buildChromiumExtension rec {
  pname = "ublacklist";
  version = "7.6.0";
  src = fetchzip {
    url = "https://github.com/iorate/ublacklist/releases/download/v${version}/ublacklist-v${version}-chrome.zip";
    sha256 = "0bkm9ircy4iz6dwminhr459l1c980mvdf7lpszcj5p76dxwspz5h";
    stripRoot = false;
  };
}
