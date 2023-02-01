{ config, lib, inputs, ... }:
{
  imports = with inputs.nixos-hardware.nixosModules; [
    common-pc-ssd
  ];

  environment.etc."lvm/lvm.conf".text = ''
    devices {
      issue_discards = 1
    }
  '';

  systemd.services.fstrim = {
    unitConfig = {
      ConditionACPower = true;
    };
    serviceConfig = {
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };
}
