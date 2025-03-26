# Font configuration
{ pkgs, ... }:

{
  fonts = {
    # install fonts
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji-blob-bin
      corefonts
      dejavu_fonts
      freefont_ttf
      gyre-fonts # TrueType substitutes for standard PostScript fonts
      liberation_ttf
      unifont
      ngkz.sarasa-term-j-nerd-font
      ngkz.vcr-eas-font
    ];

    # Create a directory with links to all fonts in /run/current-system/sw/share/X11/fonts
    fontDir.enable = true;

    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [ "Noto Sans CJK JP" ];
        serif = [ "Noto Serif CJK JP" ];
        emoji = [ "Blobmoji" ];
        monospace = [ "Sarasa Term J Nerd Font" ];
      };
      # cache32Bit = true;
      confPackages = [ pkgs.ngkz.blobmoji-fontconfig ];
    };
  };
}
