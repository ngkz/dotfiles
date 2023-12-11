{ vimUtils, fetchFromGitHub, ... }:
let
  inherit (vimUtils) buildVimPlugin;
in
buildVimPlugin {
  name = "flygrep-vim";
  src = fetchFromGitHub {
    owner = "wsdjeg";
    repo = "FlyGrep.vim";
    rev = "7a74448ac7635f8650127fc43016d24bb448ab50";
    sha256 = "1dSVL027AHZaTmTZlVnJYkwB80VblwVDheo+4QDsO8E=";
  };
}
