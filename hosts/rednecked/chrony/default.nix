{ config, pkgs, ... }: {
  services.timesyncd.enable = false;
  services.chrony = {
    enable = true;
    extraConfig = ''
      include /etc/chrony.d/*.conf
      allow
    '';
  };

  hosts.rednecked.network.internalInterfaces.allowedUDPPorts = [ 123 ];
  tmpfs-as-root.persistentDirs = [ config.services.chrony.directory ];
  systemd.tmpfiles.rules = [
    "d /etc/chrony.d 0755 root root -"
    "d ${config.tmpfs-as-root.storage}${config.services.chrony.directory} 0775 root chrony -"
  ];
  environment.systemPackages = [ pkgs.chrony ];

  services.networkd-dispatcher.rules."10-update-chrony" = {
    onState = [ "configured" ];
    script = builtins.readFile (pkgs.substituteAll {
      src = ./update-chrony.py;
      inherit (pkgs) python3 systemd;
    });
  };
}
