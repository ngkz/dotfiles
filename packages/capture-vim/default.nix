{ vimUtils, fetchFromGitHub, ... }:
let
  inherit (vimUtils) buildVimPlugin;
in
buildVimPlugin {
  name = "capture-vim";
  src = fetchFromGitHub {
    owner = "tyru";
    repo = "capture.vim";
    rev = "857ee11cfe1193948d3d45dcb8d511fded8533fb";
    sha256 = "nYMNXdHFVaw6cFKGT9KiHzrlQ7u76WdA4UlvaII+bok=";
  };
}
