{ config, pkgs, ... }: {
  services.networkd-dispatcher.rules."20-update-dns-record" = {
    onState = [ "configured" ];
    script = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail

      if [[ "$IFACE" = wan_hgw ]] && [[ "$AdministrativeState" = configured ]]; then
        systemctl start --no-block update-dns-aaaa
      elif [[ "$IFACE" = wan_pppoe ]] && [[ "$AdministrativeState" = configured ]]; then
        systemctl start --no-block update-dns-a
      fi
    '';
  };

  systemd.services.update-dns-a = {
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      # https://api.cloudflare.com/client/v4/zones
      zone=d05ae5f71b9d1a14d3060969c37e7c1b #f2l.cc
      # https://api.cloudflare.com/client/v4/zones/$zone/dns_records
      record_A=05dec190ff4baa481788336c347bc38d #f2l.cc A

      ipaddr=$(${pkgs.iproute2}/bin/ip addr show dev wan_pppoe | ${pkgs.gawk}/bin/awk '/inet/ {print $2}')

      echo "updating A record ip=$ipaddr"

      i=0
      while ! ${pkgs.curl}/bin/curl \
                --silent \
                --show-error \
                -X PATCH \
                "https://api.cloudflare.com/client/v4/zones/$zone/dns_records/$record_A" \
                -H "Authorization: Bearer $(<${config.age.secrets.cloudflare-api-key.path})" \
                -H "Content-Type: application/json" \
                --data "{
                  \"content\": \"$ipaddr\",
                  \"name\": \"@\",
                  \"type\": \"A\"
                }"
      do
        # wait for dns ready
        if (( i >= 24 )); then
          exit 1
        fi
        sleep 5
        i=$((i + 1))
      done
    '';
  };

  systemd.services.update-dns-aaaa = {
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      # https://api.cloudflare.com/client/v4/zones
      zone=d05ae5f71b9d1a14d3060969c37e7c1b #f2l.cc
      # https://api.cloudflare.com/client/v4/zones/$zone/dns_records
      record_AAAA=86fa91834f8e992b8bd573158beccb5f #f2l.cc AAAA

      ip6addr=$(${pkgs.iproute2}/bin/ip -6 addr show scope global dev wan_hgw | ${pkgs.gawk}/bin/awk '/inet6/ { sub(/\/.*$/, "", $2); print $2 }')

      echo "updating AAAA record ip=$ip6addr"

      i=0
      while ! ${pkgs.curl}/bin/curl \
              --silent \
              --show-error \
              -X PATCH \
              "https://api.cloudflare.com/client/v4/zones/$zone/dns_records/$record_AAAA" \
              -H "Authorization: Bearer $(<${config.age.secrets.cloudflare-api-key.path})" \
              -H "Content-Type: application/json" \
              --data "{
                \"content\": \"$ip6addr\",
                \"name\": \"@\",
                \"type\": \"AAAA\"
              }"
      do
        # wait for dns ready
        if (( i >= 24 )); then
          exit 1
        fi
        sleep 5
        i=$((i + 1))
      done
    '';
  };

  age.secrets.cloudflare-api-key.file = ../../secrets/cloudflare-api-key.age;
}
