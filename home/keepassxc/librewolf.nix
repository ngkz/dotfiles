# KeePassXC LibreWolf integration
{ pkgs, ... }:
{
  home.file.".librewolf/native-messaging-hosts/org.keepassxc.keepassxc_browser.json".source = pkgs.substituteAll {
    src = ./org.keepassxc.keepassxc_browser.json;
    inherit (pkgs) keepassxc;
  };
}
