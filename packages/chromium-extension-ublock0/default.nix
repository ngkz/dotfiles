{ pkgs, lib, ... }:
let
  inherit (pkgs.ngkz) buildChromiumExtension;
  inherit (pkgs) fetchzip;
in
buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.43.0";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "19jq44wik3rnmn2qyqwag5hbi1m3lbbjzmkypk53vx7jmgzn1pr5";
  };
}
