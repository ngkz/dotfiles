{ stdenv, emacs, fetchFromGitHub, lib, libgccjit }: (emacs.override {
  inherit stdenv; # make stdenv overridable
  withPgtk = true;
  nativeComp = true;
}).overrideAttrs (finalAttrs: previousAttrs: {
  pname = "emacs-pgtk-nativecomp";
  version = "28.2.50";
  src = fetchFromGitHub {
    owner = "flatwhatson";
    repo = "emacs";
    rev = "e8938d599ef0cd43ee9ef11d811f91a5b0fbc4c4"; # pgtk-nativecomp-dev
    sha256 = "2ojKi5x66wUXTNvMbZOdJwVZIQ9FgLQs7+JNm5GjzLU=";
  };
  patches = [ ];
  # from: https://github.com/nix-community/emacs-overlay/blob/c1143602cb97fa717bacdf5668ceca1bb487918d/overlays/emacs.nix
  # XXX: remove when https://github.com/NixOS/nixpkgs/pull/193621 is merged
  postPatch = previousAttrs.postPatch +
    (lib.optionalString (previousAttrs ? NATIVE_FULL_AOT)
      (
        let backendPath = (lib.concatStringsSep " "
          (builtins.map (x: ''\"-B${x}\"'') [
            # Paths necessary so the JIT compiler finds its libraries:
            "${lib.getLib libgccjit}/lib"
            "${lib.getLib libgccjit}/lib/gcc"
            "${lib.getLib stdenv.cc.libc}/lib"

            # Executable paths necessary for compilation (ld, as):
            "${lib.getBin stdenv.cc.cc}/bin"
            "${lib.getBin stdenv.cc.bintools}/bin"
            "${lib.getBin stdenv.cc.bintools.bintools}/bin"
          ]));
        in
        ''
          substituteInPlace lisp/emacs-lisp/comp.el --replace \
              "(defcustom comp-libgccjit-reproducer nil" \
              "(setq native-comp-driver-options '(${backendPath}))
          (defcustom comp-libgccjit-reproducer nil"
        ''
      ));
})
