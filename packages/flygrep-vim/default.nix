{ vimUtils, fetchFromGitHub, ... }:
let
  inherit (vimUtils) buildVimPlugin;
in
buildVimPlugin {
  name = "flygrep-vim";
  src = fetchFromGitHub {
    owner = "wsdjeg";
    repo = "FlyGrep.vim";
    rev = "0cb3146f9700460b7c924277c5b9b07b30ddc68e";
    hash = "sha256-yu6Win14A7CMBf0Bhi9Lti1pAARJS1TqDRvowAbTip8=";
  };
}
