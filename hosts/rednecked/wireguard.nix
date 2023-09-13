{ config, pkgs, ... }: {
  systemd.network = {
    netdevs = {
      "20-wireguard" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets."wireguard-rednecked-private.key".path;
          ListenPort = 51820;
        };
        wireguardPeers = [
          {
            # peregrine
            wireguardPeerConfig = {
              AllowedIPs = [
                "192.168.70.2/32"
                "2400:4051:c520:1ef2:e804:a60c:ce29:eca7/128" # TODO dynamic prefix
              ];
              PublicKey = "XUVACg5OrqWzwi+jl2yzl3oWIUsCQksvZW5JSeBbTFg=";
              PersistentKeepalive = 25;
            };
          }
          {
            # noguchi-pc
            wireguardPeerConfig = {
              AllowedIPs = [
                "192.168.70.3/32"
                "2400:4051:c520:1ef2:d5c8:218f:1106:82b9/128" # TODO dynamic prefix
              ];
              PublicKey = "ftZZBc7ToneXygRUg5YBWRDLbt9AlUm11/QrmsXXsis=";
              PersistentKeepalive = 25;
            };
          }
          {
            # barbet
            wireguardPeerConfig = {
              AllowedIPs = [
                "192.168.70.4/32"
                "2400:4051:c520:1ef2:fd7e:d3e4:5bf0:be40/128" # TODO dynamic prefix
              ];
              PublicKey = "a1XeocAbD6Two0/Zb2Pd7lfAwFc7eKG1Lsrk85nMQ30=";
              PersistentKeepalive = 25;
            };
          }
        ];
      };
    };
    networks = {
      "30-wireguard" = {
        matchConfig.Name = "wg0";
        networkConfig = {
          DHCPPrefixDelegation = true;
          IPForward = true;
        };
        dhcpPrefixDelegationConfig = {
          UplinkInterface = "wan_hgw";
          SubnetId = 2;
          Announce = false;
          Token = "::1";
        };
        address = [
          "192.168.70.1/24"
        ];
        linkConfig.RequiredForOnline = false;
      };
    };
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];

  services.networkd-dispatcher.rules."30-update-wireguard-rules" = {
    onState = [ "configured" "no-carrier" "off" ];
    script = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail

      dest=/etc/nftables.d/10-wireguard-rules.nft

      newrules=$(cat <<EOS
      table inet wireguard {

        define local_ip4 = {
          $(${pkgs.iproute2}/bin/ip -4 addr | ${pkgs.gawk}/bin/awk '/inet/ && !/127\.0\.0\.1/ {
                                                                      sub(/\/([0-9]+)/, "", $2);
                                                                      if ( ln > 0 ) { printf "," }
                                                                      print $2
                                                                      ln += 1
                                                                    }')
        }

        define local_ip6 = {
          $(${pkgs.iproute2}/bin/ip -6 addr | ${pkgs.gawk}/bin/awk '/inet6/ && !/ ::1\// && !/ fe80::/ {
                                                                      sub(/\/([0-9]+)/, "", $2);
                                                                      if ( ln > 0 ) { printf "," }
                                                                      print $2
                                                                      ln += 1
                                                                    }')
        }

        chain multiplex {
          type nat hook prerouting priority dstnat;

          ip daddr \$local_ip4 udp dport 53 @th,64,32 0x01000000 redirect to :51820 comment "redirect wireguard (IPv4)"
          ip6 daddr \$local_ip6 udp dport 53 @th,64,32 0x01000000 redirect to :51820 comment "redirect wireguard (IPv6)"
        }

        chain clamp {
          type filter hook forward priority mangle;
          iifname "wg0" tcp flags syn tcp option maxseg size set rt mtu comment "clamp MSS to Path MTU"
        }
      }
      EOS
      )

      if [[ ! -e "$dest" ]] || [[ "$newrules" != "$(<$dest)" ]]; then
        echo "update-wireguard-rules: updating rules"
        cat <<<"$newrules" >"$dest"
        systemctl restart nftables
      fi
    '';
  };


  environment.systemPackages = with pkgs; [ wireguard-tools ];

  age.secrets."wireguard-rednecked-private.key" = {
    file = ../../secrets/wireguard-rednecked-private.key.age;
    owner = "root";
    group = "systemd-network";
    mode = "0640";
  };
}
