let
  peregrine = "age1vukcr575kygdjrkz6e4c8n5asx42re3nm0at757kul0w57vt4seqnmuadr";
  rednecked = "age1y5nnvfvje8yay3rvdx0z6pzmjr9hxvks9y06u35xsv8udyxgpsyq2uk58s";
  noguchi2-pc = "age18wpcwkuwwv6adne8j7sratmte7nfda0hmumveypx0jcucdvwderqrtgye3";
in
{
  "user-password-hash-peregrine.age".publicKeys = [ peregrine ];
  "user-password-hash-noguchi2-pc.age".publicKeys = [ noguchi2-pc ];
  "user-password-hash-rednecked.age".publicKeys = [ rednecked ];
  "parents-home-1f-a.nmconnection.age".publicKeys = [ peregrine ];
  "parents-home-1f-g.nmconnection.age".publicKeys = [ peregrine ];
  "parents-home-2f.nmconnection.age".publicKeys = [ peregrine ];
  "phone.nmconnection.age".publicKeys = [ peregrine noguchi2-pc ];
  "syncthing.json.age".publicKeys = [ peregrine rednecked noguchi2-pc ];
  "8657BC028746A06C68F352BA86EE58CD1294C73E.key.age".publicKeys = [ peregrine noguchi2-pc ];
  "8227E10D40D92D39449DB2B615655DB542EA9FAF.key.age".publicKeys = [ peregrine noguchi2-pc ];
  "grub-password-hash.age".publicKeys = [ peregrine noguchi2-pc ];
  "db.crt.age".publicKeys = [ peregrine noguchi2-pc ];
  "db.key.age".publicKeys = [ peregrine noguchi2-pc ];
  "grub.key.age".publicKeys = [ peregrine noguchi2-pc ];
  "IFC.nmconnection.age".publicKeys = [ noguchi2-pc ];
  "wireguard-rednecked-private.key.age".publicKeys = [ rednecked ];
  "wireguard-noguchi2-pc.nmconnection.age".publicKeys = [ noguchi2-pc ];
  "wireguard-peregrine.nmconnection.age".publicKeys = [ peregrine ];
  "pppoe-creds.age".publicKeys = [ rednecked ];
  "cloudflare-api-key.age".publicKeys = [ rednecked ];
  "0000docomo.nmconnection.age".publicKeys = [ peregrine noguchi2-pc ];
  "IBARAKI-FREE-Wi-Fi.nmconnection.age".publicKeys = [ peregrine noguchi2-pc ];
  "cache-priv-key-peregrine.pem".publicKeys = [ peregrine ];
}
