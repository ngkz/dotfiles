{ lib, config, pkgs, ... }:
let
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
      rev = "9c3d1951e3d125b9dadd348f6c1c46f26c4a3a24";
      sha256 = "Mt8jiTJFJwjAhTwrvuMy0RLLNrf2eZa572iD5ApX7ws=";
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
    TimeoutStartSec = "1h";
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
          ~/.config/emacs/bin/doom sync -u -!
          echo "$newhash" > $DOOMLOCALDIR/hash
        fi
      fi
    '';
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
    proselint

    # lang/nix
    nixfmt
    rnix-lsp

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
  ];
  home.tmpfs-as-home.persistentDirs = [
    ".config/doom-local"
    ".config/doom-load"
    ".local/share/doom"
  ];
}
