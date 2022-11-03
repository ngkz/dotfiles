{ fetchFromGitHub, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "useragent-switcher";
  version = "0.4.8";
  src = fetchFromGitHub {
    owner = "ray-lothian";
    repo = "UserAgent-Switcher";
    rev = "01ef202834738a69f6c8dca3f4cfa3afa3706480";
    sha256 = "scCmGnzahrY0G33M5RvdW9dHYDBVjSV/nijdKVFgDXg=";
  };
  buildPhase = ''
    cp -Lr extension/chrome ../source_chrome
    cd ../source_chrome
    ls -al
  '';
}
