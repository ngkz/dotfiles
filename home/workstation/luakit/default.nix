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
    sha256 = "17rgfwypbri0j0rwyj2wdqfzvi14fifqvzh35as22xp94lg6yjza";
  };
  home.file.".local/share/luakit/adblock/easyprivacy.txt".source = pkgs.fetchurl {
    url = "https://easylist.to/easylist/easyprivacy.txt";
    sha256 = "0xcmzvkjri3gwfqh5jwwg3mdmxfzf7fipgjjy69nz58x0qdpmza5";
  };
  home.file.".local/share/luakit/adblock/fanboy-cookiemonster.txt".source = pkgs.fetchurl {
    url = "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt";
    sha256 = "0agba1rq8q1yv5mai9kynj4c43hx90hhybhyh19fdysm3340bn3k";
  };
  home.file.".local/share/luakit/adblock/adguard-japanese-filter.txt".source = pkgs.fetchurl {
    url = "https://filters.adtidy.org/extension/ublock/filters/7.txt";
    sha256 = "1b773z97w8wiq954scb4ypjkp6bbhapm5f4zlbzlq48di94yhq8j";
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
