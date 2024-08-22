# disable usb keyboard wakeup
{ ... }:
{
  services.udev.extraRules = ''
    # ThinkPad TrackPoint Keyboard
    ATTR{idProduct}=="6047",ATTR{idVendor}=="17ef",ATTR{power/wakeup}="disabled"
  '';
}
