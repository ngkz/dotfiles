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

  environment.etc."ppp/ip-up" = {
    mode = "0555";
    text = ''
      #!${pkgs.bash}/bin/bash
      ifname=$1
      localip=$4

      # XXX workaround for https://github.com/systemd/systemd/issues/26356
      ${pkgs.systemd}/bin/networkctl reconfigure "$ifname"

      # update DNS
      zone=d05ae5f71b9d1a14d3060969c37e7c1b #f2l.cc
      record=05dec190ff4baa481788336c347bc38d #f2l.cc A
      ${pkgs.curl}/bin/curl -X PATCH \
           "https://api.cloudflare.com/client/v4/zones/$zone/dns_records/$record" \
           -H "Authorization: Bearer $(<${config.age.secrets.cloudflare-api-key.path})" \
           -H "Content-Type: application/json" \
           --data "{
             \"content\": \"$localip\",
             \"name\": \"@\",
             \"type\": \"A\"
           }"
    '';
  };

  age.secrets.cloudflare-api-key.file = ../../secrets/cloudflare-api-key.age;

  networking.nftables.ruleset = ''
    table ip network-extra-v4 {
      chain clamp {
        type filter hook forward priority mangle;
        oifname "wan_pppoe" tcp flags syn tcp option maxseg size set rt mtu comment "clamp MSS to Path MTU"
      }
    }
  '';
}
