{ config, pkgs, ... }: {
  services.pppd = {
    enable = true;
    peers.wan = {
      enable = true;
      autostart = true;
      config = ''
        plugin pppoe.so
        ifname wan_pppoe
        nic-wan_hgw

        lcp-echo-failure 10
        lcp-echo-interval 60
        maxfail 0
        noipdefault
        nodefaultroute
        noauth

        # https://qa.flets-w.com/faq/show/2473?site_domain=default
        mtu 1454
        mru 1454

        file ${config.age.secrets.pppoe-creds.path}
      '';
    };
  };

  age.secrets.pppoe-creds.file = ../../secrets/pppoe-creds.age;

  # XXX workaround for https://github.com/systemd/systemd/issues/26356
  environment.etc."ppp/ip-up" = {
    mode = "0555";
    text = ''
      #!${pkgs.runtimeShell}
      ${pkgs.systemd}/bin/networkctl reconfigure "$1"
    '';
  };

  networking.nftables.ruleset = ''
    table ip network-extra-v4 {
      chain clamp {
        type filter hook forward priority mangle;
        oifname "wan_pppoe" tcp flags syn tcp option maxseg size set rt mtu comment "clamp MSS to Path MTU"
      }
    }
  '';
}
