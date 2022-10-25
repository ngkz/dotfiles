{ config, pkgs, ... }:
{
  home.sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];
  # home.sessionVariables = {
  #   DOOMDIR = "${config.xdg.configHome}/doom-config";
  #   DOOMLOCALDIR = "${config.xdg.configHome}/doom-local";
  # };

  xdg.configFile = {
    # "doom/config.el".text = "…";
    # "doom/init.el".text = "…";
    # "doom/packages.el".text = "…";
    "emacs" = {
      source = pkgs.fetchFromGitHub {
        owner = "doomemacs";
        repo = "doomemacs";
        rev = "9f22a0a2a5191cf57184846281164f478df4b7ac";
        sha256 = "02E4VHBFf9rG9NAwKrpK7Wb9mE8WKzGB9RG2lWxFr0E=";
      };
      # onChange = "${pkgs.writeShellScript "doom-change" ''
      #   export DOOMDIR="${config.home.sessionVariables.DOOMDIR}"
      #   export DOOMLOCALDIR="${config.home.sessionVariables.DOOMLOCALDIR}"
      #   if [ ! -d "$DOOMLOCALDIR" ]; then
      #     ${config.xdg.configHome}/emacs/bin/doom -y install
      #   else
      #     ${config.xdg.configHome}/emacs/bin/doom -y sync -u
      #   fi
      # ''}";
    };
  };

  home.packages = with pkgs; [
    # DOOM Emacs dependencies
    # binutils
    # ripgrep
    # gnutls
    # fd
    # imagemagick
    # zstd
    # nodePackages.javascript-typescript-langserver
    # sqlite
    # editorconfig-core-c
    # emacs-all-the-icons-fonts
    # required dependencies
    git
    #ngkz.emacs-puregtk-nativecomp
    ripgrep
    # optional dependencies
    coreutils # basic GNU utilities
    fd
    #clang
  ];
  # home.tmpfs-as-home.persistentDirs = [
  #   ".config/doom-local"
  # ];
}
