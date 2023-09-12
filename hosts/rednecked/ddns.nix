{ config, pkgs, ... }: {
  services.networkd-dispatcher.rules.update-dns = {
    onState = [ "configured" ];
    script = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail

      # https://api.cloudflare.com/client/v4/zones
      zone=d05ae5f71b9d1a14d3060969c37e7c1b #f2l.cc
      # https://api.cloudflare.com/client/v4/zones/$zone/dns_records
      record_A=05dec190ff4baa481788336c347bc38d #f2l.cc A
      record_AAAA=86fa91834f8e992b8bd573158beccb5f #f2l.cc AAAA

      if [[ "$IFACE" = wan_hgw ]] && [[ "$AdministrativeState" = configured ]]; then
        read -r ip6addr _ <<<"$IP6_ADDRS"

        echo "update-dns: updating AAAA record ip=$ip6addr"
        ${pkgs.curl}/bin/curl -s \
             -X PATCH \
             "https://api.cloudflare.com/client/v4/zones/$zone/dns_records/$record_AAAA" \
             -H "Authorization: Bearer $(<${config.age.secrets.cloudflare-api-key.path})" \
             -H "Content-Type: application/json" \
             --data "{
               \"content\": \"$ip6addr\",
               \"name\": \"@\",
               \"type\": \"AAAA\"
             }"
      elif [[ "$IFACE" = wan_pppoe ]] && [[ "$AdministrativeState" = configured ]]; then
        read -r ipaddr _ <<<"$IP_ADDRS"

        echo "update-dns: updating A record ip=$ipaddr"
        ${pkgs.curl}/bin/curl -s \
             -X PATCH \
             "https://api.cloudflare.com/client/v4/zones/$zone/dns_records/$record_A" \
             -H "Authorization: Bearer $(<${config.age.secrets.cloudflare-api-key.path})" \
             -H "Content-Type: application/json" \
             --data "{
               \"content\": \"$ipaddr\",
               \"name\": \"@\",
               \"type\": \"A\"
             }"
      fi
    '';
  };

  age.secrets.cloudflare-api-key.file = ../../secrets/cloudflare-api-key.age;
}
