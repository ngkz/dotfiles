# btop: modern top command
{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.btop;
in
{
  options.btop.tmpfs-as-root-filter =
    mkEnableOption "filter tmpfs-as-root and btrfs related directories";

  config = {
    programs.btop.enable = true;
    home.shellAliases.top = "btop";

    programs.btop.settings.disks_filter = mkIf cfg.tmpfs-as-root-filter
      "exclude=/var/persist /var/snapshots /var/swap /var/log";
  };
}
