{ ... }:
{
  services.kanshi = {
    enable = true;
    profiles = {
      undocked = {
        outputs = [{
          criteria = "eDP-1";
          scale = 1.0;
        }];
      };
      single-hdmi = {
        outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1080@60Hz";
            position = "0,0";
            scale = 1.25;
          }
          {
            criteria = "HDMI-A-1";
            position = "1920,0";
          }
        ];
      };
      docked = {
        outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1080@60Hz";
            position = "0,1080";
            scale = 1.25;
          }
          {
            criteria = "ViewSonic Corporation VX3211-4K VJJ201920351";
            mode = "3840x2160@30Hz";
            position = "1920,0";
          }
          {
            criteria = "Unknown UHD HDMI 0x00000000";
            mode = "3840x2160@30Hz";
            position = "5760,0";
          }
        ];
      };
    };
  };
}
