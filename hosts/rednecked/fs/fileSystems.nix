{ bootDev, rootDev, hddDev }:
let
  # only options in first mounted subvolume will take effect so all mounts must have same options
  rootOpts = [ "compress=zstd:1" "lazytime" ];
in
{
  "/boot" = {
    device = bootDev;
    fsType = "vfat";
  };
  "/nix" = {
    device = rootDev;
    fsType = "btrfs";
    options = rootOpts ++ [ "subvol=nix" "noatime" ];
  };
  "/var/persist" = {
    device = rootDev;
    fsType = "btrfs";
    neededForBoot = true;
    options = rootOpts ++ [ "subvol=persist" ];
  };
  "/var/swap" = {
    device = rootDev;
    fsType = "btrfs";
    options = rootOpts ++ [ "subvol=swap" "noatime" ];
  };
  "/var/snapshots" = {
    device = rootDev;
    fsType = "btrfs";
    options = rootOpts ++ [ "subvol=snapshots" "noatime" ];
  };
  "/var/spinningrust" = {
    device = hddDev;
    fsType = "btrfs";
    options = [ "compress=zstd:1" "lazytime" ];
  };
}
