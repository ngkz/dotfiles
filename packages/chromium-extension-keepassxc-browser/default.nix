{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.9.0.2";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "10kjl8zy7nw9m8b6k06nk4wgw23lb352s0j705fjh7zp35vciwrq";
    stripRoot = false;
  };
}
