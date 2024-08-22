# sysctl tweaks
{ lib, pkgs, ... }:
let
  inherit (lib) mkMerge;
in
{
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = mkMerge [
    {
      # use bbr congestion control algorithm
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "cake";
      "net.ipv4.tcp_notsent_lowat" = 16384;
    }
    # increase ASLR entropy
    (if (pkgs.stdenv.hostPlatform.system == "x86_64-linux") then
      {
        "vm.mmap_rnd_bits" = 32;
        "vm.mmap_rnd_compat_bits" = 16;
      }
    else builtins.throw "unknown system")
  ];
}
