{ ... }: {
  programs.hyfetch = {
    enable = true;
    settings = {
      preset = "gendernonconforming2";
      mode = "rgb";
      light_dark = "dark";
      lightness = 0.5;
      color_align = {
        mode = "horizontal";
        custom_colors = [ ];
        fore_back = null;
      };
    };
  };
}
