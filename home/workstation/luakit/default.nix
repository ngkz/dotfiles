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
    sha256 = "05ph1mik2zhcs4cn23wbzvxl53p6j03cg3clsgsyg2bbrbjqj9na";
  };
  home.file.".local/share/luakit/adblock/easyprivacy.txt".source = pkgs.fetchurl {
    url = "https://easylist.to/easylist/easyprivacy.txt";
    sha256 = "1gsmg77x6ws7mczqm18s80lwanb0nkddxxi7c0qkk0yrfcih17np";
  };
  home.file.".local/share/luakit/adblock/fanboy-cookiemonster.txt".source = pkgs.fetchurl {
    url = "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt";
    sha256 = "0m9jgjx30sg7q7s1wg28r9pnzy7ydxrhx9f8132z5wv793h0h3gz";
  };
  home.file.".local/share/luakit/adblock/adguard-japanese-filter.txt".source = pkgs.fetchurl {
    url = "https://filters.adtidy.org/extension/ublock/filters/7.txt";
    sha256 = "1jn02rpad2ind29d6jx9z5rhyclw2jcjgmv4slcx7miph7q46cxk";
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
