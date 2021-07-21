{ config, pkgs, ... }:
{
  systemd.tmpfiles.rules = [
    "d /nix/persist/home/user/.local/share/zsh - user users -"
    "L /home/user/.local/share/zsh - - - - /nix/persist/home/user/.local/share/zsh"
  ];

  home-manager.users.user.programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    history = {
      extended = true;
      path = "${config.home-manager.users.user.xdg.dataHome}/zsh/history";
      size = 100000;
      save = 100000;
    };
    initExtraFirst = ''
      # Enable Powerlevel10k instant prompt. Should stay close to the top of .
      # Initialization code that may require console input (password prompts, [y/n]
      # confirmations, etc.) must go above this block; everything else may go below.
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';
    initExtra = ''
      source ${./foot-integration.zsh}

      # fuzzy tab completion
      # fzf-tab needs to be loaded after compinit, but before plugins which will wrap widgets, such as zsh-autosuggestions or fast-syntax-highlighting!!
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      # auto suggestion
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

      # syntax highlighting
      source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh

      # prompt theme
      source ${./p10k.zsh}
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      # Remove superfluous blanks from each command line being added to the history list.
      setopt hist_reduce_blanks

      # Undefine oh-my-zsh ls aliases
      unalias lsa
      unalias l
      unalias ll
      unalias la
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git" # git aliases
        "colored-man-pages"
        "zbell" #notifications for long running commands
        "extract"
        "dirpersist" # persistent directory stack
        "dirhistory" # alt+left, alt+right, alt+up, alt+down
      ];
      extraConfig = ''
        # Uncomment the following line if you want to change the command execution time
        # stamp shown in the history command output.
        # You can set one of the optional three formats:
        # "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
        # or set a custom format using the strftime function format specifications,
        # see 'man strftime' for details.
        HIST_STAMPS="yyyy-mm-dd"

        # Enable command auto-correction.
        ENABLE_CORRECTION="true"
      '';
      custom = "${config.home-manager.users.user.xdg.configHome}/zsh/custom";
    };
    shellAliases = {
      # modern unix commands
      cat = "bat -p";
      top = "bpytop";
      dig = "dog";
      ls = "exa --icons --time-style=iso --git";
      ll = "ls -lgh";
      la = "ls -a";
      lt = "ls -lgh --tree";
      lla = "ll -a";

      # safe rm,cp,mv
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
    };
    shellGlobalAliases = {
      H = "| head";
      T = "| tail";
      ET = "|& tail";
      G = "| rg";
      EG = "|& rg";
      L = "| less";
      LL = "|& less -r";
      N = "&>/dev/null";
      E = ">/dev/null";
      NE = "2>/dev/null";
    };
  };

  environment.pathsToLink = ["/share/zsh"];

  # Ctrl+T: find and insert path
  # Alt+C: find and chdir
  # Ctrl+R: search history
  home-manager.users.user.programs.fzf.enableZshIntegration = true;

  home-manager.users.user.xdg.configFile."zsh/custom/lib/termsupport.zsh".source = ./termsupport-patched.zsh;
  home-manager.users.user.programs.command-not-found.enable = true;
}
