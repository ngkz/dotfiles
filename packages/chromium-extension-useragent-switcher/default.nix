{ pkgs, lib, ... }:
let
  inherit (pkgs.my) buildChromiumExtension;
  inherit (pkgs) fetchFromGitHub;
in
buildChromiumExtension rec {
  pname = "useragent-switcher";
  version = "0.4.8";
  src = fetchFromGitHub {
    owner = "ray-lothian";
    repo = "UserAgent-Switcher";
    rev = "b30e7e2df746fbaa8989f1586e92241477f09b51";
    sha256 = "oA7vk2IohuFIVO7iRmFRNZMZ2Er9FhMzo4cQSHaeObg=";
  };
  sourceRoot = "source/extension/chrome";
}
