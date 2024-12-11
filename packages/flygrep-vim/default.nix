{ vimUtils, fetchFromGitHub, ... }:
let
  inherit (vimUtils) buildVimPlugin;
in
buildVimPlugin {
  name = "flygrep-vim";
  src = fetchFromGitHub {
    owner = "wsdjeg";
    repo = "FlyGrep.vim";
    rev = "16f48cc95632a0f39dfe03a1eb818f5832e28c87";
    hash = "sha256-b5T0EUP/vCSAT/QcIDMO8R2kAqddDtzgGdnUa+7hpBI=";
  };
}
