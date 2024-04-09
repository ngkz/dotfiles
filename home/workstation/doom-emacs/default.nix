{ lib, config, pkgs, ... }:
let
  inherit (lib) mkForce;
  inherit (lib.ngkz) rot13;
in
{
  home.sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];
  home.sessionVariables = {
    DOOMDIR = "${config.xdg.configHome}/doom";
    DOOMLOCALDIR = "${config.xdg.configHome}/doom-local";
    DOOMPROFILELOADFILE = "${config.xdg.configHome}/doom-load/doom-load.el";
  };

  xdg.configFile = {
    "doom/config.el".text = builtins.replaceStrings [ "@email@" ] [ (rot13 "abthpuv.xnmhgbfv+Am0Gwsg4@tznvy.pbz") ] (builtins.readFile ./config.el);
    "doom/init.el".source = ./init.el;
    "doom/packages.el".source = ./packages.el;
    "emacs".source = pkgs.fetchFromGitHub {
      owner = "doomemacs";
      repo = "doomemacs";
      rev = "a8d612385fcc001f711f21eda2e275a78cdf1efb";
      hash = "sha256-dqpqM5LD2wB+l2JiV2Meybxgtjiws6gDh6P60OjdPyM=";
    };
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-pgtk;
    extraPackages = (epkgs: with epkgs; [
      # term/vterm
      vterm
    ]);
  };

  services.emacs = {
    enable = true;
    client.enable = true;
    startWithUserSession = "graphical";
  };

  systemd.user.services.emacs.Service = {
    TimeoutStartSec = "3h";
    Environment = [
      "DOOMDIR=${config.home.sessionVariables.DOOMDIR}"
      "DOOMLOCALDIR=${config.home.sessionVariables.DOOMLOCALDIR}"
      "DOOMPROFILELOADFILE=${config.home.sessionVariables.DOOMPROFILELOADFILE}"
    ];
    ExecStartPre = pkgs.writeScript "doom-sync" ''
      #!${pkgs.bash}/bin/bash -l
      set -euo pipefail

      newhash=$(nix-hash $(realpath ~/.config/doom/{init.el,packages.el} ~/.config/emacs/) && echo ${config.programs.emacs.package})
      if [ ! -d "$DOOMLOCALDIR/etc" ]; then
        echo "doom install"
        ~/.config/emacs/bin/doom install -!
        echo "$newhash" > $DOOMLOCALDIR/hash
      else
        # run doom sync only when really necessary
        if [ ! -e "$DOOMLOCALDIR/hash" ] ||  [ "$(<$DOOMLOCALDIR/hash)" != "$newhash" ]; then
          echo "configuration changed, doom sync"
          ~/.config/emacs/bin/doom sync --gc -!
          echo "$newhash" > $DOOMLOCALDIR/hash
        fi
      fi
    '';
    Restart = mkForce "no";
  };

  systemd.user.services.org-external-calendars = {
    Unit = {
      Description = "Update external org-mode calendars";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.substituteAll {
        src = ./org-external-calendars.sh;
        isExecutable = true;
        path = lib.makeBinPath (with pkgs; [ coreutils curl gawk ngkz.ical2org ]);
        inherit (pkgs) bash;
      }}";
    };
  };

  systemd.user.timers.org-external-calendars = {
    Unit = {
      Description = "Update external org-mode calendars";
    };

    Timer = {
      Unit = "org-external-calendars.service";
      OnBootSec = "5m";
      OnUnitInactiveSec = "1day1sec";
    };
    Install.WantedBy = [ "timers.target" ];
  };

  home.packages = with pkgs; [
    # required dependencies
    git
    ripgrep
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    # optional dependencies
    coreutils # basic GNU utilities
    fd
    llvmPackages.clang-unwrapped

    # editor/format
    asmfmt
    nodePackages.prettier
    #cmake-format
    dockfmt
    #html-tidy
    nodePackages.lua-fmt
    #nixfmt
    black
    shfmt
    nodePackages.prettier-plugin-toml

    # chckers/aspell
    # (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))

    # checkers/grammar
    languagetool

    # tools/ansible
    # ansible

    # tools/docker
    nodePackages.dockerfile-language-server-nodejs

    # tools/editorconfig
    editorconfig-core-c

    # tools/lookup
    ripgrep
    sqlite

    # lang/cc
    cmake-language-server
    bear
    glslang

    # lang/data
    libxml2.bin

    # lang/javascript
    nodejs
    nodePackages.npm

    # lang/lua
    lua-language-server

    # lang/markdown
    python3Packages.grip
    pandoc
    nodePackages.markdownlint-cli
    # proselint

    # lang/nix
    nixfmt
    #rnix-lsp # XXX rnix-lsp pulls in vulnerable nix

    # lang/org
    texlive.combined.scheme-medium
    gnuplot

    # lang/python
    python3Packages.python-lsp-server
    python3Packages.pyflakes
    python3Packages.isort
    pipenv
    python3Packages.nose
    python3Packages.pytest

    # lang/rst
    rstfmt

    # lang/ruby
    ruby
    rubyPackages.solargraph
    rubocop

    # lang/rust
    rustc
    cargo
    rust-analyzer

    # lang/sh
    shellcheck
    nodePackages.bash-language-server
    bashdb

    # lang/web
    nodePackages.vscode-html-languageserver-bin
    nodePackages.vscode-css-languageserver-bin
    nodePackages.js-beautify
    nodePackages.stylelint
    html-tidy

    # alert
    libnotify
  ];
  tmpfs-as-home.persistentDirs = [
    ".config/doom-local"
    ".config/doom-load"
    ".local/share/doom"
  ];
}
