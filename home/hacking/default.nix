{ config, lib, pkgs, ... }:
{
  tmpfs-as-home.persistentDirs = [
    ".ghidra"
  ];

  xdg.configFile."gdb/gdbinit".source = ./gdbinit;
}
