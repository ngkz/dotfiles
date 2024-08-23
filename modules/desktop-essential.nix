{ ... }:

{
  # install debug symbols
  environment.enableDebugInfo = true;

  xdg.sounds.enable = true;
  services.openssh.settings.X11Forwarding = true;
}
