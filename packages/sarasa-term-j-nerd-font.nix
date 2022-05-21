{ lib, fetchzip }:

let
  version = "0.36.3";
in
fetchzip {
  name = "sarasa-term-j-nerd-font-${version}";

  url = "https://github.com/jonz94/Sarasa-Gothic-Nerd-Fonts/releases/download/v${version}/sarasa-term-j-nerd-font.zip";
  sha256 = "sha256-1bk+AxVbozR2O4s9mq+z8ygvqvSxfPRAVXZxmGBzpR4=";

  postFetch = ''
    unzip $downloadedFile
    install -m444 -Dt $out/share/fonts/truetype *.ttf
  '';

  meta = with lib; {
    description = " Nerd fonts patched Sarasa Gothic font";
    homepage = "https://github.com/jonz94/Sarasa-Gothic-Nerd-Fonts";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
