{ config, lib, pkgs, ... }:
{
  home.tmpfs-as-home.persistentDirs = [
    ".ghidra"
  ];

  xdg.configFile."gdb/gdbinit".source = ./gdbinit;
}
