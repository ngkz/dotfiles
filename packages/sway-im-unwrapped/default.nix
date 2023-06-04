{ sway-unwrapped, stdenv, fetchpatch, ... }:

(sway-unwrapped.override {
  inherit stdenv; # make stdenv overridable
}).overrideAttrs (finalAttrs: previousAttrs: {
  pname = "sway-im-unwrapped";
  patches = previousAttrs.patches ++ [
    (fetchpatch {
      name = "0001-text_input-Implement-input-method-popups.patch";
      url = "https://github.com/swaywm/sway/commit/d1c6e44886d1047b3aa6ff6aaac383eadd72f36a.patch"; # PR 7229 2023-01-04
      hash = "sha256-LsCoK60FKp3d8qopGtrbCFXofxHT+kOv1e1PiLSyvsA=";
    })
  ];
})
