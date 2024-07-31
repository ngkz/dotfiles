{ vimUtils, fetchFromGitHub, ... }:
let
  inherit (vimUtils) buildVimPlugin;
in
buildVimPlugin {
  name = "flygrep-vim";
  src = fetchFromGitHub {
    owner = "wsdjeg";
    repo = "FlyGrep.vim";
    rev = "02e8a753590f739c77d9e79edd36e3633d490b7b";
    hash = "sha256-Msq/NXizNYkj/RHn7f84xfdiO03+rOtRp3Jb7cbh5vg=";
  };
}
