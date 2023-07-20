{ ... }: {
  dconf.settings = {
    "org/virt-manager/virt-manager" = {
      xmleditor-enabled = true;
    };

    "org/virt-manager/virt-manager/connections" = {
      uris = [ "qemu:///system" ];
      autoconnect = [ "qemu:///system" ];
    };

    "org/virt-manager/virt-manager/console" = {
      auto-redirect = false;
    };
  };
}
