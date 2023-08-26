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
              AllowedIPs = [ "192.168.70.2/32" "fd55:86a5:7398::2/128" ];
              PublicKey = "XUVACg5OrqWzwi+jl2yzl3oWIUsCQksvZW5JSeBbTFg=";
            };
          }
          {
            # noguchi-pc
            wireguardPeerConfig = {
              AllowedIPs = [ "192.168.70.3/32" "fd55:86a5:7398::3/128" ];
              PublicKey = "ftZZBc7ToneXygRUg5YBWRDLbt9AlUm11/QrmsXXsis=";
            };
          }
        ];
      };
    };
    networks = {
      "30-wireguard" = {
        matchConfig.Name = "wg0";
        networkConfig = {
          IPMasquerade = "ipv6";
          IPForward = true;
        };
        address = [ "192.168.70.1/24" "fd55:86a5:7398::1/64" ];
      };
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 53 51820 ];
    extraCommands = ''
      # clean up rules
      ip46tables -t nat -D PREROUTING -j wireguard 2>/dev/null || true
      ip46tables -t nat -F wireguard 2>/dev/null || true
      ip46tables -t nat -X wireguard 2>/dev/null || true

      ip46tables -t nat -N wireguard

      # redirect WireGuard connection to 51820/udp
      ip46tables -t nat -A wireguard -p udp --dport 53 -m addrtype --dst-type LOCAL -m u32 --u32 "0>>22&0x3C@8=0x01000000" -j REDIRECT --to-port 51820

      ip46tables -t nat -A PREROUTING -j wireguard
    '';
    extraStopCommands = ''
      ip46tables -t nat -D PREROUTING -j wireguard 2>/dev/null || true
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
