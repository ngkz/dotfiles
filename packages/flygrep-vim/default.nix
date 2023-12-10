{ vimUtils, fetchFromGitHub, ... }:
let
  inherit (vimUtils) buildVimPlugin;
in
buildVimPlugin {
  name = "flygrep-vim";
  src = fetchFromGitHub {
    owner = "wsdjeg";
    repo = "FlyGrep.vim";
    rev = "71737401648c85af21e1af28819cad55f6ab2b62";
    sha256 = "FgaU1SlFpMWmQsnReo8UPQHtoISB05w6+MO1NhnnZqE=";
  };
}
