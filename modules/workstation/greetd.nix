# greetd display manager
# sway + gtkgreet
{ config, pkgs, ... }:
{
  environment.etc =
    let
      background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
    in
    {
      "greetd/sway-config".text = ''
        output * bg ${background} fill
        seat seat0 xcursor_theme Adwaita
        exec "GTK_THEME=Adwaita:dark ${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -s /etc/greetd/gtkgreet.css; swaymsg exit"
        bindsym Mod4+shift+e exec swaynag \
            -t warning \
            -m 'What do you want to do?' \
            -b 'Suspend' 'systemctl suspend' \
            -b 'Poweroff' 'systemctl poweroff' \
            -b 'Reboot' 'systemctl reboot'
        include /etc/sway/config.d/*
      '';

      # gtkgreet list of login environments
      "greetd/environments".text = ''
        systemd-cat -t sway-session sway
        zsh
      '';

      "greetd/gtkgreet.css".text = ''
        window {
          background-image: url("file://${background}");
          background-size: cover;
          background-position: center;
        }
      '';
    };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.systemd}/bin/systemd-cat -t sway-greeter sway --config /etc/greetd/sway-config";
        user = "greeter";
      };

      initial_session = {
        command = "systemd-cat -t sway-session sway";
        user = "user";
      };
    };
    restart = false;
  };

  environment.systemPackages = with pkgs; [
    gnome.adwaita-icon-theme # gtkgreet
  ];
}
