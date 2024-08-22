# sudo
{ ... }:
{
  security.sudo = {
    execWheelOnly = true;
    extraConfig = ''
      # rollback results in sudo lectures after each reboot
      Defaults lecture = never
    '';
  };
}
