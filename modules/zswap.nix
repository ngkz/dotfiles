{ ... }: {
  # compress memory and store in RAM before swapping to disk
  boot.kernelParams = [
    "zswap.enabled=1"
  ];
  boot.kernelModules = [
    "lz4"
    "z3fold"
  ];
  systemd.services.config-zswap = {
    description = "Configure zswap";
    after = [ "systemd-modules-load.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      echo lz4 >/sys/module/zswap/parameters/compressor
      echo z3fold >/sys/module/zswap/parameters/zpool
    '';
  };
}
