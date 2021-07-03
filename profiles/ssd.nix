{ config, pkgs, ... }:
{
  # trim
  services.fstrim.enable = true;

  environment.etc."lvm/lvm.conf".text = ''
    devices {
      issue_discards = 1
    }
  '';
}
