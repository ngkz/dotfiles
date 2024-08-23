{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    drivers = with pkgs; [ epson-escpr2 ];
  };
  hardware.printers = {
    ensureDefaultPrinter = "EPSON-EW-M754T-Series";
    ensurePrinters = [
      {
        description = "EPSON EW-M754T Series";
        deviceUri = "dnssd://EPSON%20EW-M754T%20Series._ipp._tcp.local/?uuid=cfe92100-67c4-11d4-a45f-381a526218ab";
        model = "epson-inkjet-printer-escpr2/Epson-EW-M754T_Series-epson-escpr2-en.ppd";
        name = "EPSON-EW-M754T-Series";
      }
    ];
  };
  programs.system-config-printer.enable = true;

  # Scanner support
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan ];
  };

  users.users.user.extraGroups = [
    "scanner"
    "lp"
  ];
}

