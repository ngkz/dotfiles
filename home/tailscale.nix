{ pkgs, ... }:

{
  programs.gnome-shell.extensions = with pkgs.gnomeExtensions; [
    { package = tailscale-status; }
  ];
}
