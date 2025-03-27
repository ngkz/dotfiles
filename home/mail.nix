{ config, osConfig, lib, pkgs, ... }:
let
  inherit (lib.ngkz) rot13;
in
{
  xdg.enable = true;

  accounts.email.accounts = {
    "mailbox.org" = {
      primary = true;
      address = rot13 "xa@s2y.pp";
      aliases = [
        (rot13 "atxm@znvyobk.bet")
        (rot13 "abthpuv.xnmhgbfv@tznvy.pbz")
      ];
      realName = "Kazutoshi Noguchi";
      userName = rot13 "atxm@znvyobk.bet";
      passwordCommand = "${pkgs.coreutils}/bin/cat ${osConfig.age.secrets.email-password-mailbox-org.path}";
      imap = {
        host = "imap.mailbox.org";
        port = 993;
        tls.enable = true;
      };
      smtp = {
        host = "smtp.mailbox.org";
        port = 465;
        tls.enable = true;
      };
      gpg = {
        key = config.gpgFingerprint;
      };
      signature = {
        showSignature = "append";
        text = ''
          Kazutoshi Noguchi / 野口和敏
          ${rot13 "xa@s2y.pp"}
          https://f2l.cc/
        '';
      };
      msmtp.enable = true;
      thunderbird = {
        enable = true;
        perIdentitySettings = id: {
          "mail.identity.id_${id}.archive_granularity" = 0; # use single folder archive. thunderbird mobile does not support yearly archive :(
        };
      };
    };
  };

  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
      withExternalGnupg = true;
      search = {
        force = true;
        default = "DuckDuckGo";
      };
      settings = {
        "mail.identity.default.compose_html" = false;
        "network.cookie.cookieBehavior" = 2; # deny all cookies
        "privacy.donottrackheader.enabled" = true;
        "mail.openpgp.fetch_pubkeys_from_gnupg" = true;
      };
    };
  };

  # thunderbird as default mail app
  xdg.mimeApps.defaultApplications = {
    "essage/rfc822" = "thunderbird.desktop";
    "x-scheme-handler/mailto" = "thunderbird.desktop";
    "text/calendar" = "thunderbird.desktop";
    "text/x-vcard" = "thunderbird.desktop";
  };

  # TODO switch to xdg.autostart after 25.05 upgrade
  xdg.configFile."autostart/thunderbird.desktop".source = "${pkgs.thunderbird}/share/applications/thunderbird.desktop";

  programs.msmtp.enable = true;

  tmpfs-as-home.persistentDirs = [
    # msmtp
    ".local/share/msmtp"
    # thunderbird
    ".thunderbird/default"
  ];
}
