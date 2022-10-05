{ config, pkgs, lib, ... }:
let
  keygrips = [
    # 685C 0C22 43FC 78BB 8D26  932F 9912 4A42 67F5 6B75 [E]
    "8657BC028746A06C68F352BA86EE58CD1294C73E"
    # 7081 B064 7E5C B656 7F18  36FA C2AC 8CAE 60CE DC4F [S]
    "8227E10D40D92D39449DB2B615655DB542EA9FAF"
  ];
in
lib.mkMerge ([{
  services.dbus.packages = [ pkgs.gcr ]; # gnome3 pinentry
}] ++ map
  (keygrip: {
    # install private keys
    home-manager.users.user.xdg.dataFile."gnupg/private-keys-v1.d/${keygrip}.key".source =
      config.home-manager.users.user.lib.file.mkOutOfStoreSymlink config.age.secrets."${keygrip}.key".path;
    age.secrets."${keygrip}.key" = {
      file = ../../secrets/${keygrip}.key.age;
      owner = "user";
      group = "users";
      mode = "0400";
    };
  })
  keygrips)
