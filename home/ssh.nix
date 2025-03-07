# SSH
# See also: modules/ssh
{ lib, ... }:
let
  inherit (lib.ngkz) rot13;
in
{
  programs.ssh = {
    enable = true;
    serverAliveInterval = 60;
    #https://qiita.com/tango110/items/c8194d43b46fa2a712d1
    extraConfig = ''
      IPQoS none
    '';
    matchBlocks = {
      "github.com" = {
        user = "git";
      };
      "gitlab.com" = {
        user = "git";
      };
      niwase = {
        hostname = rot13 "gfhxhon.avjnfr.arg";
        user = "ngkz";
        port = 49224;
      };
      peregrine = {
        hostname = "peregrine.v.f2l.cc";
        user = "user";
      };
      rednecked = {
        hostname = "rednecked.v.f2l.cc";
        user = "user";
      };
    };
  };

}
