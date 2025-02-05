{ vimUtils, fetchFromGitHub, ... }:
let
  inherit (vimUtils) buildVimPlugin;
in
buildVimPlugin {
  name = "flygrep-vim";
  src = fetchFromGitHub {
    owner = "wsdjeg";
    repo = "FlyGrep.vim";
    rev = "54bd78ee9e58406fd1698b5ffe51518742238df3";
    hash = "sha256-hc0blsSQifHLOFG2dOXyvfUqzo3Ezmlmbp+UV+igDGE=";
  };
}
