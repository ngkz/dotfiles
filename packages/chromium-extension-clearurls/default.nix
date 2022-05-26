{ pkgs, lib, ... }:
let
  inherit (pkgs.my) buildChromiumExtension;
  inherit (pkgs) fetchzip;
in
buildChromiumExtension rec {
  pname = "clearurls";
  version = "1.23.1";
  src = fetchzip {
    url = "https://github.com/ClearURLs/Addon/releases/download/${version}/ClearURLs-${version}-chrome.zip";
    sha256 = "1k2m7fkj5ysfcgpl7xnhmd0i797axd7z71p4jnrsngf19rdqsjd5";
    stripRoot = false;
  };
}
