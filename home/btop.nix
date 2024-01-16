# btop: modern top command
{ ... }: {
  programs.btop.enable = true;
  home.shellAliases.top = "btop";
  # NixOS-only disks filter settings in: nixos.nix
}
