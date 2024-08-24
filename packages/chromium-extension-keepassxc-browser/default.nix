{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.9.3";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "1kf6zs9phw203qr5im2ybfj6zj305rd0r1skbli4l87h033dvc4m";
    stripRoot = false;
  };
}
