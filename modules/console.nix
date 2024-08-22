# VT configuration

{ ... }:
{
  # Remap Caps Lock To Ctrl
  console.useXkbConfig = true;
  services.xserver.xkb = {
    layout = "jp";
    options = "ctrl:nocaps";
  };
}
