let
  key-client = "age1yxv3ga7qy5dgeqrcd4gumcuw7qkex7jymmgam9w0zrjg2gp7mq8sjeverv";
  keys-all = [ key-client ];
  keys-client = [ key-client ];
in
{
  "user-password-hash.age".publicKeys = keys-all;
  "parents-home-1f-a.nmconnection.age".publicKeys = keys-all;
  "parents-home-1f-g.nmconnection.age".publicKeys = keys-all;
  "parents-home-2f.nmconnection.age".publicKeys = keys-all;
  "phone.nmconnection.age".publicKeys = keys-all;
  "syncthing.json.age".publicKeys = keys-all;
  "8657BC028746A06C68F352BA86EE58CD1294C73E.key.age".publicKeys = keys-client;
  "8227E10D40D92D39449DB2B615655DB542EA9FAF.key.age".publicKeys = keys-client;
}
