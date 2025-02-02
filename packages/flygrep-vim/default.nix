{ vimUtils, fetchFromGitHub, ... }:
let
  inherit (vimUtils) buildVimPlugin;
in
buildVimPlugin {
  name = "flygrep-vim";
  src = fetchFromGitHub {
    owner = "wsdjeg";
    repo = "FlyGrep.vim";
    rev = "221e4b2de8af3ad4190610bacee6f7afc43e2194";
    hash = "sha256-ZLV8NbyJrzNYw8vE4pIlkO+jwM4id3uN1zO1aripb/M=";
  };
}
