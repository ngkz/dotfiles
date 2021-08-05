{ pkgs, lib, ... }:
let
  inherit (lib) versions getVersion;
in {
  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint ];
  };
  hardware.printers = {
    ensureDefaultPrinter = "MX923";
    ensurePrinters = [
      {
        description = "Canon PIXUS MX923";
        deviceUri = "dnssd://Canon%20MX920%20series._ipp._tcp.local/?uuid=00000000-0000-1000-8000-84BA3B85F5A1";
        model = "gutenprint.${versions.majorMinor (getVersion pkgs.gutenprint)}://bjc-MX920-series/expert";
        name = "MX923";
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
    "scanner" "lp"
  ];
}

