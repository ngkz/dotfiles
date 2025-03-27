# GNOME desktop
# See also: home/gnome
{ pkgs, lib, ... }: {
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.power-profiles-daemon.enable = false;
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gnome-text-editor
    geary
    gnome-tour
    gnome-calendar
    gnome-contacts
    gnome-maps
    # gnome-backgrounds
    orca
    totem
  ];
  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];
  services.gnome.gnome-keyring.enable = lib.mkForce false; # conflcts with keepassxc secret service integration

  services.displayManager.autoLogin = {
    enable = true;
    user = "user";
  };
  services.xserver.displayManager.gdm.autoLogin.delay = 3; #XXX https://github.com/NixOS/nixpkgs/issues/9843
}
