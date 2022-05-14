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
}
