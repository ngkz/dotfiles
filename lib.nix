{ lib }:
let
  inherit (lib) stringToCharacters;
  alphabets = stringToCharacters "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
  alphabets_rot13 = stringToCharacters "nopqrstuvwxyzabcdefghijklmNOPQRSTUVWXYZABCDEFGHIJKLM";
in
{
  rot13 = builtins.replaceStrings alphabets alphabets_rot13;
}
