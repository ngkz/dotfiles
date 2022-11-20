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
    sha256 = "1pgx0153vs9iayc60flv5c7dd1f7kl25wk559l4m8bf8p9r4cdr0";
  };
  home.file.".local/share/luakit/adblock/easyprivacy.txt".source = pkgs.fetchurl {
    url = "https://easylist.to/easylist/easyprivacy.txt";
    sha256 = "0jyi0m7wy92qswwi7p7lcs64vsv51scbszrclwdiqjr1i2n86qcn";
  };
  home.file.".local/share/luakit/adblock/fanboy-cookiemonster.txt".source = pkgs.fetchurl {
    url = "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt";
    sha256 = "1qw3p8ixhnji1qrv9cv6x3490rq63a80c0km61h1mrg109ppnm60";
  };
  home.file.".local/share/luakit/adblock/adguard-japanese-filter.txt".source = pkgs.fetchurl {
    url = "https://filters.adtidy.org/extension/ublock/filters/7.txt";
    sha256 = "1lljwyp5vfavs81xf1xm9j1glfvvzhwfccdy29vn88g9ll0jvy6p";
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
