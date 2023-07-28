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

    cores = mkOption {
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

    sharedDirectories = mkOption {
      type = with types; attrsOf
        (submodule {
          options = {
            source = mkOption {
              type = str;
              description = "The path of the directory to share";
            };
            target = mkOption {
              type = path;
              description = "The mount point of the directory inside the VM";
            };
          };
        });
      default = { };
      example = {
        my-share = { source = "/path/to/be/shared"; target = "/mnt/shared"; };
      };
      description = ''
        An attributes set of directories that will be shared with the
        virtual machine using virtiofs.
        The attribute name will be used as the mount tag.
      '';
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
