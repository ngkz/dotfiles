{ sway-unwrapped, ... }:

sway-unwrapped.overrideAttrs (finalAttrs: previousAttrs: {
  pname = "sway-im-unwrapped";
  patches = previousAttrs.patches ++ [
    ./0001-text_input-Implement-input-method-popups.patch
  ];
})
