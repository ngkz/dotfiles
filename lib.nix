{ lib }:
let
  inherit (lib) lists attrsets stringToCharacters;
  alphabets = stringToCharacters "abcdefghijklmnopqrstuvwxyz";
  alphabets_rot13 = stringToCharacters "nopqrstuvwxyzabcdefghijklm";
in
{
  overlayPaths = prev: paths: fn: builtins.foldl'
    (
      result: path:
        let
          head = builtins.head path;
        in
        attrsets.recursiveUpdate
          (if !result ? "${head}" && prev ? "${head}" then result // {
            "${head}" = prev."${head}";
          } else result)
          (attrsets.setAttrByPath path (fn (attrsets.getAttrFromPath path prev)))
    )
    { }
    paths;

  rot13 = builtins.replaceStrings alphabets alphabets_rot13;
}
