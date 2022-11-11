{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    luakit
  ];

  xdg.configFile."luakit/userconf.lua".source = ./userconf.lua;
  xdg.configFile."luakit/theme.lua".text = builtins.replaceStrings
    [ "@luakit@" ] [ "${pkgs.luakit}" ]
    (builtins.readFile ./theme.lua);

  home.file.".local/share/luakit/adblock/easylist.txt".source = pkgs.fetchurl {
    url = "https://easylist.to/easylist/easylist.txt";
    sha256 = "0g0nx4c49jnafh7wik73xqk90zn335zj8xb4lbamih2g0c5lzds5";
  };
  home.file.".local/share/luakit/adblock/easyprivacy.txt".source = pkgs.fetchurl {
    url = "https://easylist.to/easylist/easyprivacy.txt";
    sha256 = "0q708hjgrpf4dccmg4gc5fkj71iyvc9ndqriwyp0nh5yrqnlvfzb";
  };
  home.file.".local/share/luakit/adblock/fanboy-cookiemonster.txt".source = pkgs.fetchurl {
    url = "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt";
    sha256 = "0imx79864l4wx0anyr8rvl0c2qihfql6l0qhxzl2skm05dp7aaqm";
  };
  home.file.".local/share/luakit/adblock/adguard-japanese-filter.txt".source = pkgs.fetchurl {
    url = "https://filters.adtidy.org/extension/ublock/filters/7.txt";
    sha256 = "0pnsg3ks626lg1g5j4d9w0yrybdc5s8fvsh5h29lgz11ffns1h4w";
  };

  home.file.".local/share/luakit/bookmarks.db".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/misc/otg/luakit-bookmarks.db";

  home.tmpfs-as-home.persistentFiles = [
    ".local/share/luakit/allowed_certificates.db"
    ".local/share/luakit/command-history"
    ".local/share/luakit/cookies.db"
    ".local/share/luakit/downloads.db"
    ".local/share/luakit/history.db"
    ".local/share/luakit/styles.db"
  ];

  home.tmpfs-as-home.persistentDirs = [
    ".local/share/luakit/indexeddb"
    ".local/share/luakit/local_storage"
    ".local/share/luakit/styles"
    ".local/share/luakit/session"
  ];

  xdg.mimeApps.defaultApplications = {
    "text/html" = "luakit.desktop";
    "text/xml" = "luakit.desktop";
    "application/xhtml+xml" = "luakit.desktop";
    "application/xhtml_xml" = "luakit.desktop";
    "application/xml" = "luakit.desktop";
    "application/rdf+xml" = "luakit.desktop";
    "application/rss+xml" = "luakit.desktop";
    "x-scheme-handler/http" = "luakit.desktop";
    "x-scheme-handler/https" = "luakit.desktop";
  };
}
