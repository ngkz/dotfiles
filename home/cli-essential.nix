# my cli environment configuration for all hosts
{ inputs, config, lib, pkgs, ... }:
let
  inherit (lib) types mkOption;
in
{
  imports = [
    ./tmpfs-as-home.nix
    ./zsh
    inputs.nix-index-database.hmModules.nix-index
    ./tealdeer.nix
    ./dust.nix
    ./ripgrep.nix
    ./fzf.nix
    ./bat.nix
    ./eza.nix
    ./btop.nix
    ./neovim
  ];

  options.cli-essential.pythonPackages = mkOption {
    type = with types; functionTo (listOf package);
    default = (_: [ ]);
    description = "python libraries available to default python interpreter";
  };

  config = {
    tmpfs-as-home.persistentDirs = [
      ".local/share/nix" # nix repl history
    ];

    programs.jq.enable = true;
    btop.enable = true;

    home.shellAliases = {
      strings = "strings -a";

      # safe rm,cp,mv
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
    };

    home.packages = with pkgs; [
      # more modern unix commands
      fd # find
      httpie # modern curl
      ncdu # du
      sd #modern sed
      procs # modern ps
      choose # modern cut
      delta # diff

      iotop
      s-tui
      stress

      inetutils
      inotify-tools
      netcat-openbsd
      p7zip
      pigz
      (python3.withPackages config.cli-essential.pythonPackages)
      wget
      file
      python3Packages.yq
      openssl
      unixtools.xxd
      socat
      bc
      dig
    ];
  };
}
