let
  peregrine = "age1vukcr575kygdjrkz6e4c8n5asx42re3nm0at757kul0w57vt4seqnmuadr";
  rednecked = "age1y5nnvfvje8yay3rvdx0z6pzmjr9hxvks9y06u35xsv8udyxgpsyq2uk58s";
  mauritius = "age1mj2suswkxz0j3t8up3p6hxmwnetn5nzknlkdl6uvrwpr0k6d8gesx455lc";
in
{
  "user-password-hash-peregrine.age".publicKeys = [ peregrine ];
  "user-password-hash-rednecked.age".publicKeys = [ rednecked ];
  "user-password-hash-mauritius.age".publicKeys = [ mauritius ];
  "parents-home-1f-a.nmconnection.age".publicKeys = [ peregrine ];
  "parents-home-1f-g.nmconnection.age".publicKeys = [ peregrine ];
  "parents-home-2f.nmconnection.age".publicKeys = [ peregrine ];
  "home-a.nmconnection.age".publicKeys = [ peregrine ];
  "phone.nmconnection.age".publicKeys = [ peregrine ];
  "syncthing.json.age".publicKeys = [ peregrine rednecked ];
  "8657BC028746A06C68F352BA86EE58CD1294C73E.key.age".publicKeys = [ peregrine ];
  "8227E10D40D92D39449DB2B615655DB542EA9FAF.key.age".publicKeys = [ peregrine ];
  "grub-password-hash.age".publicKeys = [ peregrine ];
  "db.crt.age".publicKeys = [ peregrine ];
  "db.key.age".publicKeys = [ peregrine ];
  "grub.key.age".publicKeys = [ peregrine ];
  "0000docomo.nmconnection.age".publicKeys = [ peregrine ];
  "IBARAKI-FREE-Wi-Fi.nmconnection.age".publicKeys = [ peregrine ];
  "cache-priv-key-peregrine.pem.age".publicKeys = [ peregrine ];
  "PD-50.nmconnection.age".publicKeys = [ peregrine ];
  "email-password-mailbox-org.age".publicKeys = [ peregrine ];
}
