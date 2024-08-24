# personal printer and scanner configuration
{ pkgs, ... }:
{
  # printing
  services.printing = {
    enable = true;
    drivers = with pkgs; [ epson-escpr2 cnijfilter2 ];
  };
  hardware.printers = {
    ensureDefaultPrinter = "Canon-TS5400-Series";
    ensurePrinters = [
      {
        description = "EPSON EW-M754T Series";
        deviceUri = "dnssd://EPSON%20EW-M754T%20Series._ipp._tcp.local/?uuid=cfe92100-67c4-11d4-a45f-381a526218ab";
        model = "epson-inkjet-printer-escpr2/Epson-EW-M754T_Series-epson-escpr2-en.ppd";
        name = "EPSON-EW-M754T-Series";
      }
      {
        description = "Canon TS5400 Series";
        deviceUri = "dnssd://Canon%20TS5400%20series._ipp._tcp.local/?uuid=00000000-0000-1000-8000-0018d8806c8b";
        model = "canonts5400.ppd";
        name = "Canon-TS5400-Series";
      }
    ];
  };
  programs.system-config-printer.enable = true;

  # scanning
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan ];
  };

  users.users.user.extraGroups = [
    "scanner"
    "lp"
  ];
}

