{ unstable, ... }:

unstable.sway-unwrapped.overrideAttrs (oldAttrs: {
  pname = "sway-im-unwrapped";
  patches = oldAttrs.patches ++ [
    ./0001-text_input-Implement-input-method-popups.patch
  ];
})
