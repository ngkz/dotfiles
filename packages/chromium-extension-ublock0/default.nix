{ pkgs, lib, ... }:
let
  inherit (pkgs.ngkz) buildChromiumExtension;
  inherit (pkgs) fetchzip;
in
buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.42.4";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "1xs63s1z95rfn8qdfcrcckm9ap0nrf2rwh3k6h1j6g8vbv49x276";
  };
}
