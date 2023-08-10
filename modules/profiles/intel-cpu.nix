{ config, lib, inputs, pkgs, ... }:
let
  inherit (inputs) nixos-hardware;
  inherit (lib) mkOption types mkIf;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-cpu-intel
  ];

  options.profiles.intel-cpu.enableGPUPowerSaving = mkOption {
    type = types.bool;
    default = true;
    description = "Enable i915 power saving options.";
  };

  config = {
    hardware.enableRedistributableFirmware = true;
    boot.kernelModules = [ "kvm-intel" ];

    environment.systemPackages = with pkgs; [
      intel-gpu-tools # intel_gpu_top
    ];

    # power saving
    boot.extraModprobeConfig = mkIf config.profiles.intel-cpu.enableGPUPowerSaving ''
      options i915 enable_fbc=1 enable_psr=2 enable_guc=2 enable_psr2_sel_fetch=1
      options drm vblankoffdelay=1
    '';
  };
}
