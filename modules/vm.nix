{ config, lib, pkgs, ... }: {
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      swtpm.enable = true;
      ovmf = {
        packages = with pkgs; [ OVMFFull.fd ];
        enable = true;
      };
      runAsRoot = false;
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  users.users.user.extraGroups = [ "libvirtd" ];

  environment.systemPackages = with pkgs; [
    virt-manager
    libguestfs
  ];

  modules.tmpfs-as-root.persistentDirs = [
    "/var/lib/libvirt"
  ];

  systemd.services.libvirtd-config.serviceConfig = {
    StateDirectory = lib.mkForce "";
    ReadWritePaths = [
      "/var/lib/libvirt"
      "${config.modules.tmpfs-as-root.storage}/var/lib/libvirt"
    ];
  };

  # nested virtualization
  boot.extraModprobeConfig = "options kvm_intel nested=1";

  systemd.tmpfiles.rules = [
    "a+ /home/user - - - - u:qemu-libvirtd:x"
    "a+ ${config.modules.tmpfs-as-root.storage}/home/user - - - - u:qemu-libvirtd:x"
  ];

}
