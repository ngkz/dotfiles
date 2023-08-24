let
  peregrine = "age1vukcr575kygdjrkz6e4c8n5asx42re3nm0at757kul0w57vt4seqnmuadr";
  noguchi-pc = "age1sg083tscjgj58w8kf3p0svg2vsz0mplynj9rve48ru9ytz9ww9xsh0vksp";
  rednecked = "age1y5nnvfvje8yay3rvdx0z6pzmjr9hxvks9y06u35xsv8udyxgpsyq2uk58s";
in
{
  "user-password-hash-peregrine.age".publicKeys = [ peregrine ];
  "user-password-hash-noguchi-pc.age".publicKeys = [ noguchi-pc ];
  "user-password-hash-rednecked.age".publicKeys = [ rednecked ];
  "parents-home-1f-a.nmconnection.age".publicKeys = [ peregrine ];
  "parents-home-1f-g.nmconnection.age".publicKeys = [ peregrine ];
  "parents-home-2f.nmconnection.age".publicKeys = [ peregrine ];
  "phone.nmconnection.age".publicKeys = [ peregrine ];
  "syncthing.json.age".publicKeys = [ peregrine noguchi-pc rednecked ];
  "8657BC028746A06C68F352BA86EE58CD1294C73E.key.age".publicKeys = [ peregrine noguchi-pc ];
  "8227E10D40D92D39449DB2B615655DB542EA9FAF.key.age".publicKeys = [ peregrine noguchi-pc ];
  "grub-password-hash.age".publicKeys = [ peregrine noguchi-pc ];
  "db.crt.age".publicKeys = [ peregrine noguchi-pc ];
  "db.key.age".publicKeys = [ peregrine noguchi-pc ];
  "grub.key.age".publicKeys = [ peregrine noguchi-pc ];
  "IFC.nmconnection.age".publicKeys = [ noguchi-pc ];
}
