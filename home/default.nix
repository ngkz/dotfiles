{
  nixos = import ./nixos.nix;
  base = import ./base.nix;
  cli-base = import ./cli-base.nix;
  zsh = import ./zsh;
  tealdeer = import ./tealdeer.nix;
  tmpfs-as-home = import ./tmpfs-as-home.nix;
  workstation = import ./workstation;
  sway-desktop = import ./sway-desktop;
  theming = import ./theming;
  neovim = import ./neovim;
  hacking = import ./hacking;
  vmm = import ./vmm.nix;
  dust = import ./dust.nix;
  ripgrep = import ./ripgrep.nix;
  fzf = import ./fzf.nix;
  bat = import ./bat.nix;
  eza = import ./eza.nix;
  btop = import ./btop.nix;
  hyfetch = import ./hyfetch.nix;
  git = import ./git.nix;
  im = import ./im;
  dev-docs = import ./dev-docs.nix;
}
