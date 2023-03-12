{ ... }: {
  # compress memory and store in RAM before swapping to disk
  boot.kernelParams = [
    "zswap.enabled=1"
  ];
  boot.initrd.kernelModules = [
    "lz4"
    "z3fold"
  ];
  boot.initrd.preDeviceCommands = ''
    echo lz4 >/sys/module/zswap/parameters/compressor
    echo z3fold >/sys/module/zswap/parameters/zpool
  '';
}
