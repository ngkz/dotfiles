{ pkgs, lib, ... }:
let
  inherit (pkgs.ngkz) buildChromiumExtension;
  inherit (pkgs) fetchzip;
in
buildChromiumExtension rec {
  pname = "ublacklist";
  version = "7.7.0";
  src = fetchzip {
    url = "https://github.com/iorate/ublacklist/releases/download/v${version}/ublacklist-v${version}-chrome.zip";
    sha256 = "0h58c9fa7vw821mvlr0rinnz8jcqds5dj05z50wika4q2023s235";
    stripRoot = false;
  };
}
