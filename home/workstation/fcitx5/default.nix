{ config, osConfig, lib, pkgs, ... }:
{
  # Fcitx5 + Mozc IM
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      ngkz.fcitx5-skk
      ngkz.fcitx5-themes
    ];
  };

  xdg.configFile."fcitx5" = {
    source = ./config;
    recursive = true;
  };

  # use default IMMMODULE (gtk2: xim, gtk3/4: wayland)
  home.sessionVariables.GTK_IM_MODULE = lib.mkForce "";

  xdg.dataFile."fcitx5/skk/dictionary_list".text =
    let
      dictdir = "${config.home.homeDirectory}/misc/skk";
      self = osConfig.system.name;
      machines = [ "peregrine" "noguchi-pc" ];
      otherMachines = builtins.filter (host: host != self) machines;
    in
    lib.concatStringsSep "\n" ([
      "encoding=UTF-8,file=${dictdir}/user-${self}.dict,mode=readwrite,type=file"
    ] ++ (map (host: "encoding=UTF-8,file=${dictdir}/user-${host}.dict,mode=readonly,type=file") otherMachines) ++ [
      "file=${pkgs.ngkz.skk-dicts}/share/SKK-JISYO.total,mode=readonly,type=file"
      "file=${pkgs.ngkz.skk-dicts}/share/SKK-JISYO.emoji,mode=readonly,type=file"
    ]);

  systemd.user.services.fcitx5-daemon = {
    Service = {
      Environment = [
        "PATH=/etc/profiles/per-user/%u/bin" # XXX Qt find plugins from PATH
      ];
    };
  };
}
