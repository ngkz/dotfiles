{ lib, config, pkgs, ... }:
let
  inherit (lib.ngkz) rot13;
in
{
  home.sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];
  home.sessionVariables = {
    DOOMDIR = "${config.xdg.configHome}/doom";
    DOOMLOCALDIR = "${config.xdg.configHome}/doom-local";
    DOOMPROFILELOADFILE = "${config.xdg.configHome}/doom-load.el";
  };

  xdg.configFile =
    let
      sync = "${pkgs.writeShellScript "doom-change" ''
      export DOOMDIR="${config.home.sessionVariables.DOOMDIR}"
      export DOOMLOCALDIR="${config.home.sessionVariables.DOOMLOCALDIR}"
      export DOOMPROFILELOADFILE="${config.home.sessionVariables.DOOMPROFILELOADFILE}"

      if [[ ! -d "$DOOMLOCALDIR/etc" ]]; then
        $VERBOSE_RUN echo "doom install"
        $DRY_RUN_CMD ${config.xdg.configHome}/emacs/bin/doom install -! || exit 1
      else
        # run doom sync only when really necessary
        newhash=$(nix-hash ~/.config/doom/{init.el,packages.el} ~/.config/emacs/)
        if [[ "$(cat $DOOMLOCALDIR/hash 2>/dev/null)" != "$newhash" ]]; then
          $VERBOSE_RUN echo "doom sync"
          $DRY_RUN_CMD ${config.xdg.configHome}/emacs/bin/doom sync -u -! || exit 1
          if [[ ! -v DRY_RUN ]]; then
            echo "$newhash" > $DOOMLOCALDIR/hash
          fi
        fi
      fi
    ''}";
    in
    {
      "doom/config.el".text = builtins.replaceStrings [ "@email@" ] [ (rot13 "abthpuv.xnmhgbfv+Am0Gwsg4@tznvy.pbz") ] (builtins.readFile ./config.el);
      "doom/init.el" = {
        source = ./init.el;
        onChange = sync;
      };
      "doom/packages.el" = {
        source = ./packages.el;
        onChange = sync;
      };
      "emacs" = {
        source = pkgs.fetchFromGitHub {
          owner = "doomemacs";
          repo = "doomemacs";
          rev = "9d4d5b756a8598c4b5c842e9f1f33148af2af8fd";
          sha256 = "SURAFrtblyvkflQz1cEQogfo31UzSvKd+UOgczUyJ8k=";
        };
        onChange = sync;
      };
    };

  programs.emacs = {
    enable = true;
    package = pkgs.ngkz.emacs-pgtk-nativecomp;
    extraPackages = (epkgs: with epkgs; [
      # term/vterm
      vterm
    ]);
  };

  services.emacs = {
    enable = true;
    client.enable = true;
  };

  xdg.mimeApps.defaultApplications = {
    "text/english" = "emacsclient.desktop";
    "text/plain" = "emacsclient.desktop";
    "text/x-makefile" = "emacsclient.desktop";
    "text/x-c++hdr" = "emacsclient.desktop";
    "text/x-c++src" = "emacsclient.desktop";
    "text/x-chdr" = "emacsclient.desktop";
    "text/x-csrc" = "emacsclient.desktop";
    "text/x-java" = "emacsclient.desktop";
    "text/x-moc" = "emacsclient.desktop";
    "text/x-pascal" = "emacsclient.desktop";
    "text/x-tcl" = "emacsclient.desktop";
    "text/x-tex" = "emacsclient.desktop";
    "application/x-shellscript" = "emacsclient.desktop";
    "text/x-c" = "emacsclient.desktop";
    "text/x-c++" = "emacsclient.desktop";
  };

  home.packages = with pkgs; [
    # required dependencies
    git
    ripgrep
    emacs-all-the-icons-fonts
    # optional dependencies
    coreutils # basic GNU utilities
    fd
    llvmPackages.clang-unwrapped

    # lang/cc
    cmake-language-server
    bear

    # lang/javascript
    nodejs
    nodePackages.npm

    # lang/markdown
    python3Packages.grip

    # lang/nix
    nixfmt
    rnix-lsp

    # lang/org
    gnuplot
    hugo

    # lang/python
    nodePackages.pyright

    # lang/rst
    sphinx

    # lang/sh
    shellcheck
    nodePackages.bash-language-server
    bashdb

    # lang/web
    nodePackages.js-beautify
    nodePackages.stylelint
    html-tidy
  ];
  home.tmpfs-as-home.persistentDirs = [
    ".config/doom-local"
  ];
  home.tmpfs-as-home.persistentFiles = [
    ".config/doom-load.el"
  ];
}
