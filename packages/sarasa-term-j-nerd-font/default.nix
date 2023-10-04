{ lib, fetchzip }:

let
  version = "0.42.1-0";
in
fetchzip {
  name = "sarasa-term-j-nerd-font-${version}";

  url = "https://github.com/jonz94/Sarasa-Gothic-Nerd-Fonts/releases/download/v${version}/sarasa-term-j-nerd-font.zip";
  sha256 = "sha256-nVeTgA6b3ewPF6trJBf7f3w+fxirdbfM52OSw8C5pDk=";

  stripRoot = false;

  postFetch = ''
    install -m444 -Dt $out/share/fonts/truetype $out/*.ttf
    shopt -s extglob dotglob
    rm -f $out/!(share)
    shopt -u extglob dotglob
  '';

  meta = with lib; {
    description = " Nerd fonts patched Sarasa Gothic font";
    homepage = "https://github.com/jonz94/Sarasa-Gothic-Nerd-Fonts";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
