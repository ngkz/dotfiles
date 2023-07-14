{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    withPython3 = false;
    withRuby = false;
    plugins = with pkgs.vimPlugins; [
      {
        type = "lua";
        config = "require('config.base16')";
        plugin = base16-vim;
      }
      {
        type = "lua";
        config = "require('config.indentline')";
        plugin = indentLine;
      }
      vim-commentary
      vim-endwise
      vim-gitgutter
      {
        type = "lua";
        config = ''
          require("config.sh")
          require("config.rust")
        '';
        plugin = vim-polyglot;
      }
      vim-repeat
      {
        type = "lua";
        config = "require('config.vim-rooter')";
        plugin = vim-rooter;
      }
      vim-rsi
      vim-table-mode
      {
        type = "lua";
        config = "require('config.flygrep')";
        #TODO move to packages
        plugin =
          (pkgs.vimUtils.buildVimPlugin {
            name = "flygrep-vim";
            src = pkgs.fetchFromGitHub {
              owner = "wsdjeg";
              repo = "FlyGrep.vim";
              rev = "7a74448ac7635f8650127fc43016d24bb448ab50";
              sha256 = "1dSVL027AHZaTmTZlVnJYkwB80VblwVDheo+4QDsO8E=";
            };
          });
      }
      {
        type = "lua";
        config = "require('config.fzf')";
        plugin = fzf-vim;
      }
      vim-surround
      bclose-vim
      (pkgs.vimUtils.buildVimPlugin {
        name = "vim-dis";
        src = ./vim-dis;
        dontBuild = true;
      })
      nvim-web-devicons # nvim-tree-lua icons
      {
        type = "lua";
        config = "require('config.nvim-tree')";
        plugin = nvim-tree-lua;
      }
      {
        type = "lua";
        config = "require('config.editorconfig-vim')";
        plugin = editorconfig-vim;
      }
      {
        type = "lua";
        config = "require('config.vim-expand-region')";
        plugin = vim-expand-region;
      }
      splitjoin-vim
      {
        type = "lua";
        config = "require('config.registers-nvim')";
        plugin = registers-nvim;
      }
      {
        type = "lua";
        config = "require('config.which-key-nvim')";
        plugin = which-key-nvim;
      }
      # nvim-treesitter
    ];
    extraPackages = with pkgs; [
      fzf
      fd
      ripgrep
    ];
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraLuaConfig = ''
      require("config.options")
      require("config.help")
      require("config.fold")
      require("config.keymap")
      require("config.session")
      vim.cmd('packadd! matchit')
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  xdg.configFile."nvim" = {
    recursive = true;
    source = ./nvim;
  };

  home.tmpfs-as-home.persistentDirs = [
    ".local/share/nvim"
    ".local/state/nvim"
  ];
}
