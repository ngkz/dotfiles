{ config, lib, inputs, pkgs, ... }:
let
  inherit (inputs) nixos-hardware;
  inherit (lib) mkOption types mkIf;
in
{
  imports = [
    "${nixos-hardware}/common/cpu/intel/kaby-lake"
  ];

  hardware.enableRedistributableFirmware = true;
  boot.kernelModules = [ "kvm-intel" ];

  environment.systemPackages = with pkgs; [
    intel-gpu-tools # intel_gpu_top
  ];

  # power saving
  boot.extraModprobeConfig = ''
    options drm vblankoffdelay=1
  '';
}
