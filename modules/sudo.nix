# sudo
{ lib, ... }:
{
  security.sudo = {
    execWheelOnly = lib.mkDefault true;
    extraConfig = ''
      # rollback results in sudo lectures after each reboot
      Defaults lecture = never
    '';
  };
}
