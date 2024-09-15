{ ... }: {
  programs.librewolf = {
    enable = true;
    settings = {
      # enable hardware video decoding
      "media.ffmpeg.vaapi.enable" = true;
      # enable firefox sync
      "identity.fxaccounts.enabled" = true;
      # remember history
      "privacy.clearOnShutdown.cache" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown.downloads" = false;
      "privacy.clearOnShutdown.formdata" = false;
      "privacy.clearOnShutdown.offlineApps" = false;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.sessions" = false;
      # turn off delete cookies and site data when librewolf is closed
      "privacy.sanitize.sanitizeOnShutdown" = false;
      # turn on confirm before closing multiple tabs
      "browser.tabs.warnOnClose" = true;
      # turn on open previous windows and tabs
      "browser.startup.page" = 3;

      "signon.rememberSignons" = false;
      "browser.compactmode.show" = true;
    };
  };

  home.file.".librewolf/profiles.ini".source = ./profiles.ini;

  tmpfs-as-home.persistentDirs = [
    ".librewolf/default"
  ];

  xdg.mimeApps.defaultApplications = {
    "text/html" = "librewolf.desktop";
    "text/xml" = "librewolf.desktop";
    "application/xhtml+xml" = "librewolf.desktop";
    "application/vnd.mozilla.xul+xml" = "librewolf.desktop";
    "x-scheme-handler/http" = "librewolf.desktop";
    "x-scheme-handler/https" = "librewolf.desktop";
  };
}
