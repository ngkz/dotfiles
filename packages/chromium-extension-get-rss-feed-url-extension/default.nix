{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "get-rss-feed-url-extension";
  version = "1.4.1";
  src = fetchzip {
    url = "https://github.com/shevabam/get-rss-feed-url-extension/archive/refs/tags/v${version}.zip";
    sha256 = "04kr5rcqyjsrn9m27ka3lxg30ydljzdx2fnbm145r5h8hyz7xg18";
  };
}
