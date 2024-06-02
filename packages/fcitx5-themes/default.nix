{ lib, fetchFromGitHub }:

fetchFromGitHub rec {
  owner = "thep0y";
  repo = "fcitx5-themes";
  rev = "013aecb0368af853b55e56fe67f890b8ca0d8859";
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
