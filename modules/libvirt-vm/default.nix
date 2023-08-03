{ config, options, pkgs, lib, extendModules, ... }:
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

    disks = mkOption {
      type = with types; attrsOf
        (submodule ({ config, ... }: {
          options = {
            pool = mkOption {
              type = str;
              default = "default";
              description = "storage pool name";
            };
            volume = mkOption {
              type = str;
              description = "name of the volume";
            };
            capacity = mkOption {
              type = ints.positive;
              description = "volume capacity (MiB)";
            };
            format = mkOption {
              type = enum [ "raw" "bochs" "qcow" "qcow2" "qed" "vmdk" ];
              default = "qcow2";
              description = "volume file format";
            };
            mountTo = mkOption {
              type = nullOr str;
              default = null;
            };
            fsType = mkOption {
              type = nullOr (enum [ "ext4" "btrfs" ]);
              default = null;
            };
            autoFormat = mkOption {
              type = bool;
              default = config.mountTo != null;
            };
          };
        }));
      default = { };
      description = "virtual disks. the attribute name is device name";
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

    fileSystems = options.fileSystems;

    variant = mkOption {
      description = "Machine configuration to be added for the VM";
      inherit (libvirtVMVariant) type;
      default = { };
      visible = "shallow";
    };

    extraCreateVMCommands = mkOption {
      type = types.lines;
      default = "";
      description = "Additional bash commands to be run right before starting the VM";
    };

    extraDestroyVMCommands = mkOption {
      type = types.lines;
      default = "";
      description = "Additional bash commands to be run after destroying the VM";
    };
  };

  config = {
    system.build = {
      libvirtVM = lib.mkDefault config.modules.libvirt-vm.variant.system.build.libvirtVM;
    };
  };
}
