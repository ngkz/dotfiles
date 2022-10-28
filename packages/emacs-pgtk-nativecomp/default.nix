{ stdenv, emacs, fetchFromGitHub }: (emacs.override {
  inherit stdenv; # make stdenv overridable
  withPgtk = true;
  nativeComp = true;
}).overrideAttrs(finalAttrs: previousAttrs: {
  pname = "emacs-pgtk-nativecomp";
  version = "28.2.50";
  src = fetchFromGitHub {
    owner = "flatwhatson";
    repo = "emacs";
    rev = "e8938d599ef0cd43ee9ef11d811f91a5b0fbc4c4"; # pgtk-nativecomp-dev
    sha256 = "2ojKi5x66wUXTNvMbZOdJwVZIQ9FgLQs7+JNm5GjzLU=";
  };
  patches = [];
})
