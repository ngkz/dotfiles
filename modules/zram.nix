{ config, ... }: {
  # https://github.com/pop-os/default-settings/pull/163/files
  zramSwap = {
    enable = true;
    memoryPercent = 100;
    memoryMax = 16384 * 1024 * 1024;
    algorithm = "zstd";
  };

  boot.kernel.sysctl = {
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.swappiness" = 180;
    "vm.page-cluster" = if config.zramSwap.algorithm == "zstd" then 0 else 1;
  };

  systemd.services.zram-sysctl = {
    description = "Apply additional zram configurations";
    after = [ "systemd-sysctl.service" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      # Ensure at least 1% of total memory is free to avoid system freeze.
      MINIMUM=$(${pkgs.gawk}/bin/awk '/MemTotal/ {printf "%.0f", $2 * 0.01}' /proc/meminfo)
      CURRENT=$(${pkgs.procps}/bin/sysctl vm.min_free_kbytes | ${pkgs.gawk}/bin/awk '{print $3}')
      if [ "$MINIMUM" -gt "$CURRENT" ]; then
          ${pkgs.procps}/bin/sysctl -w "vm.min_free_kbytes=$MINIMUM"
      fi
    '';
  };
}
