{ lib, fetchFromGitHub }:

fetchFromGitHub rec {
  owner = "thep0y";
  repo = "fcitx5-themes";
  rev = "9d6e437289aa8de61d2c198b2e6ce4b5edea204f";
  sha256 = "sha256-aPs6YQ9JRScCUTCM1ko7o0imX4GJmhWeIqJCaoGfL7g=";
  name = "${repo}-${builtins.substring 0 6 rev}";

  postFetch = ''
    mkdir -p $out/share/fcitx5/themes
    mv $out/{autumn,green,spring,summer,transparent-green,winter} $out/share/fcitx5/themes
    shopt -s extglob dotglob
    rm -rf $out/!(share)
    shopt -u extglob dotglob
  '';
}
