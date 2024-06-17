{ sway-unwrapped, stdenv, fetchpatch, ... }:

(sway-unwrapped.override {
  inherit stdenv; # make stdenv overridable
}).overrideAttrs (finalAttrs: previousAttrs: {
  pname = "sway-im-unwrapped";
  patches = previousAttrs.patches ++ [
    ./0001-text_input-Implement-input-method-popups.patch
    ./0002-chore-fractal-scale-handle.patch
    ./0003-chore-left_pt-on-method-popup.patch
  ];
})
