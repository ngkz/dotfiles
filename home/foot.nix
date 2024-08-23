{ pkgs, ... }:

let
  canberra-gtk-play = "${pkgs.libcanberra-gtk3}/bin/canberra-gtk-play";
in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Monospace:size=9";
        dpi-aware = "no";
      };

      bell = {
        urgent = "yes";
        command = "${canberra-gtk-play} -i bell";
        command-focused = "yes";
      };

      scrollback = {
        lines = 65536;
      };

      colors = {
        # Base16 Monokai
        # Author: Wimer Hazenberg (http://www.monokai.nl)
        foreground = "f8f8f2";
        background = "272822";
        alpha = 0.8;

        # 16 color space
        # Black, Gray, Silver, White
        regular0 = "272822";
        bright0 = "75715e";
        regular7 = "f8f8f2";
        bright7 = "f9f8f5";

        # Red
        regular1 = "f92672";
        bright1 = "f92672";

        # Green
        regular2 = "a6e22e";
        bright2 = "a6e22e";

        # Yellow
        regular3 = "f4bf75";
        bright3 = "f4bf75";

        # Blue
        regular4 = "66d9ef";
        bright4 = "66d9ef";

        # Purple
        regular5 = "ae81ff";
        bright5 = "ae81ff";

        # Teal
        regular6 = "a1efe4";
        bright6 = "a1efe4";

        # Extra colors
        "16" = "fd971f";
        "17" = "cc66ee";
        "18" = "383838";
        "19" = "49483e";
        "20" = "a59f85";
        "21" = "f5f4f1";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}
