{ config, ... }: let
  files = [
    "parents-home-1f-a.nmconnection"
    "parents-home-1f-g.nmconnection"
    "parents-home-2f.nmconnection"
    "phone.nmconnection"
  ];
in {
  environment.etc = builtins.foldl' (acc: file: acc // {
    "NetworkManager/system-connections/${file}".source = config.age.secrets."${file}".path;
  }) {} files;

  age.secrets = builtins.foldl' (acc: file: acc // {
    "${file}".file = ../secrets/${file}.age;
  }) {} files;
}
