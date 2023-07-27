{ config, pkgs, lib, extendModules, ... }:
let
  inherit (lib) mkOption types;

  libvirtVMVariant = extendModules {
    modules = [
      ./vm-variant.nix
    ];
  };
in
{
  options.modules.libvirt-vm = {
    uri = mkOption {
      type = types.str;
      default = "qemu:///system";
      description = "Hypervisor connection URI";
    };

    vcpu = mkOption {
      type = with types; nullOr ints.positive;
      default = null;
      description = "Number of vCPUs allocated to the guest";
    };

    memorySize = mkOption {
      type = types.ints.positive;
      default = 1024;
      description = "Guest memory size (MiB)";
    };

    diskSize = mkOption {
      type = types.ints.positive;
      default = 0;
      description = "Guest vda disk capacity (GiB). No disks are created when the capacity is zero";
    };

    sharedDirectory = mkOption {
      type = with types; nullOr path;
      default = null;
      description = "Shared directory between host and guest";
    };

    sshUser = mkOption {
      type = types.str;
      default = "user";
      description = "SSH login user";
    };

    variant = mkOption {
      description = "Machine configuration to be added for the VM";
      inherit (libvirtVMVariant) type;
      default = { };
      visible = "shallow";
    };
  };

  config = {
    system.build = {
      libvirtVM = lib.mkDefault config.modules.libvirt-vm.variant.system.build.libvirtVM;
    };
  };
}
