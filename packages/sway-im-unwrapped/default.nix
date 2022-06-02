{ sway-unwrapped, stdenv, ... }:

(sway-unwrapped.override {
  inherit stdenv; # make stdenv overridable
}).overrideAttrs (finalAttrs: previousAttrs: {
  pname = "sway-im-unwrapped";
  patches = previousAttrs.patches ++ [
    ./0001-text_input-Implement-input-method-popups.patch
  ];
})
