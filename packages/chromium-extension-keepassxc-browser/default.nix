{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.8.8.1";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "1f2pgnngigkpsfpqaz1svi2zrhczc23zzf3k6jx46rk1gkcdi5s5";
    stripRoot = false;
  };
}
