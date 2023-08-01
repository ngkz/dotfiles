{ inputs, pkgs, ... }:
let
  inherit (inputs) nixos-hardware;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-cpu-intel
  ];

  hardware.enableRedistributableFirmware = true;
  boot.kernelModules = [ "kvm-intel" ];

  environment.systemPackages = with pkgs; [
    intel-gpu-tools # intel_gpu_top
  ];

  # power saving
  boot.extraModprobeConfig = ''
    options i915 enable_fbc=1 enable_psr=2 enable_guc=2 enable_psr2_sel_fetch=1
    options drm vblankoffdelay=1
  '';
}
