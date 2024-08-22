# dev documentation
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # install dev manpages
    man-pages
    man-pages-posix
    linux-manual
    stdman
  ];
}
