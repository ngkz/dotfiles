{ pkgs, lib, ... }:
let
  inherit (pkgs.my) buildChromiumExtension;
  inherit (pkgs) fetchzip;
in
buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.7.12";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "16yrbfjyg601v7zzy7a315k8hyw4z4m0wcbp9bw1iwlpsm5hcqyi";
    stripRoot = false;
  };
}
