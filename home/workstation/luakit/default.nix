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
    sha256 = "1x028i7pb66yvin1rmjgldx45p36k4c28m0viqg7kyd3nymcn2zr";
  };
  home.file.".local/share/luakit/adblock/easyprivacy.txt".source = pkgs.fetchurl {
    url = "https://easylist.to/easylist/easyprivacy.txt";
    sha256 = "0gy1sbis9f05pnfrbm3shxa7zqw2q63f52ww05s34xi2yyfklwqk";
  };
  home.file.".local/share/luakit/adblock/fanboy-cookiemonster.txt".source = pkgs.fetchurl {
    url = "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt";
    sha256 = "0llrq0xaqbwd2y9i6mjdrw25i052gq1m2njy2pii68mxd6inng83";
  };
  home.file.".local/share/luakit/adblock/adguard-japanese-filter.txt".source = pkgs.fetchurl {
    url = "https://filters.adtidy.org/extension/ublock/filters/7.txt";
    sha256 = "14n5j8afq4hmlvjsjvgqv1d9fp9q8gla29dsk1niykmkm8inwr61";
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
