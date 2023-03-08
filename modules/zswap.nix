{ ... }: {
  # compress memory and store in RAM before swapping to disk
  boot.kernelParams = [
    "zswap.enabled=1"
    "zswap.compressor=lz4"
    "zswap.zpool=z3fold" # max 3:1 compression ratio
  ];
  boot.initrd.kernelModules = [
    "lz4"
    "z3fold"
  ];
}
