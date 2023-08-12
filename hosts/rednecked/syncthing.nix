{ lib, config, pkgs, ... }:
let
  inherit (builtins) toJSON elem attrValues;
  inherit (lib.attrsets) mapAttrsToList mapAttrs' filterAttrs;
  inherit (lib) escapeShellArg concatStringsSep;

  syncthing = "${pkgs.syncthing}/bin/syncthing";
  jq = "${pkgs.jq}/bin/jq";
  xq = "${pkgs.python3Packages.yq}/bin/xq";

  user = "user";

  folders = dataDir:
    let
      pcs = [ "peregrine" "noguchi-pc" "rednecked" ];
      all = [ "peregrine" "noguchi-pc" "barbet" "rednecked" ];
      personal = [ "peregrine" "barbet" "rednecked" ];
      personal-pcs = [ "peregrine" "rednecked" ];
    in
    {
      "~/docs" = {
        id = "docs";
        path = "${dataDir}/docs";
        devices = pcs;
        ignore = ''
          /all
        '';
      };
      "~/docs/all" = {
        id = "docs-all";
        path = "${dataDir}/docs/all";
        devices = all;
      };
      "~/music" = {
        id = "music";
        path = "${dataDir}/music";
        devices = personal;
      };
      "~/pics" = {
        id = "pics";
        path = "${dataDir}/pics";
        devices = pcs;
        ignore = ''
          /phone
          /phone-dcim
        '';
      };
      "~/pics/phone" = {
        id = "pics-phone";
        path = "${dataDir}/pics/phone";
        devices = all;
      };
      "~/pics/phone-dcim" = {
        id = "pics-phone-dcim";
        path = "${dataDir}/pics/phone-dcim";
        devices = all;
      };
      "~/videos" = {
        id = "videos";
        path = "${dataDir}/videos";
        devices = personal-pcs;
        ignore = ''
          /phone
        '';
      };
      "~/videos/phonre" = {
        id = "videos-phone";
        path = "${dataDir}/videos/phone";
        devices = personal;
      };
      "~/projects" = {
        id = "projects";
        path = "${dataDir}/projects";
        devices = pcs;
      };
      "~/work" = {
        id = "work";
        path = "${dataDir}/work";
        devices = pcs;
      };
      "~/misc" = {
        id = "misc";
        path = "${dataDir}/misc";
        devices = pcs;
        ignore = ''
          /all
        '';
      };
      "~/misc/all" = {
        id = "misc-all";
        path = "${dataDir}/misc/all";
        devices = all;
      };
    };

  devices = {
    noguchi-pc = { };
    barbet = {
      compression = "always";
    };
    peregrine = { };
  };

  deviceFolders = dataDir: filterAttrs (_: v: elem config.system.name v.devices) (folders dataDir);

  foldersJSON = dataDir: mapAttrsToList
    (
      label: fldrCfg: {
        "@label" = label;
      } // (
        mapAttrs'
          (
            name: value:
              if name == "devices" then {
                name = "device";
                value = map
                  (device: {
                    "@id" = device;
                    "@introducedBy" = "";
                    "encryptionPassword" = null;
                  })
                  value;
              } else {
                name =
                  if elem name [
                    "id"
                    "label"
                    "path"
                    "type"
                    "rescanIntervalS"
                    "fsWatcherEnabled"
                    "fsWatcherDelayS"
                    "ignorePerms"
                    "autoNormalize"
                  ] then "@${name}" else name;
                inherit value;
              }
          )
          (filterAttrs (key: _: key != "ignore") fldrCfg)
      )
    )
    (deviceFolders dataDir);

  devicesJSON = mapAttrsToList
    (
      name: deviceCfg: {
        "@name" = name;
        "@id" = name;
      } // (
        mapAttrs'
          (
            name: value: {
              name = if elem name [ "compression" "introducer" "skipIntroductionRemovals" "name" ] then "@${name}" else name;
              inherit value;
            }
          )
          deviceCfg
      )
    )
    devices;

  updateConfig = cfgDir: dataDir: secrets: ''
    set -euo pipefail

    config=${escapeShellArg cfgDir}/config.xml
    secrets=${escapeShellArg secrets}
    foldersJSON='${toJSON (foldersJSON dataDir)}'
    devicesJSON='${toJSON devicesJSON}'

    if [ ! -e "$config" ]; then
      echo "config not found, generating new one"
      ${syncthing} generate --skip-port-probing >/dev/null
    fi

    foldersMerged=$(${jq} --argjson secrets "$(<"$secrets")" \
                           --argjson defaults "$(${xq} ".configuration.defaults.folder" "$config")" \
                           'map($defaults + (.device = (.device|map(.["@id"] = $secrets.ids[.["@id"]]))))' \
                           <<<"$foldersJSON")
    devicesMerged=$(${jq} --argjson secrets "$(<"${secrets}")" \
                          --argjson defaults "$(${xq} ".configuration.defaults.device" "$config")" \
                          'map($defaults + (.["@id"] = $secrets.ids[.["@id"]]))' \
                          <<<"$devicesJSON")
    newConfig=$(${xq} -x \
                      --argjson secrets "$(<"$secrets")" \
                      --argjson devices "$devicesMerged" \
                      --argjson folders "$foldersMerged" \
                      '.configuration.gui.user = ${toJSON user} |
                       .configuration.gui.password = $secrets.password |
                       .configuration.device = $devices |
                       .configuration.folder = $folders' \
                      "$config")
    if [ "$(${xq} -x <"$config")" != "$newConfig" ]; then
      echo "config changed, updating"
      echo "$newConfig" >"$config"
    fi

    # update stignore
    ${concatStringsSep "\n" (map
      (fldrCfg:
        let
          eStignore = escapeShellArg "${fldrCfg.path}/.stignore";
        in
        if fldrCfg ? ignore && fldrCfg.ignore != "" then ''
          if [ ! -e ${eStignore} ] || [ "$(<${eStignore})" != "$(echo ${escapeShellArg fldrCfg.ignore})" ]; then
            echo updating ${eStignore}
            mkdir -p ${escapeShellArg fldrCfg.path}
            echo ${escapeShellArg fldrCfg.ignore} > ${eStignore}
          fi
        '' else ''
          if [ -e ${eStignore} ]; then
            echo removing ${eStignore}
            rm ${eStignore}
          fi
        ''
      )
      (attrValues (deviceFolders dataDir))
    )}
  '';

  cfg = config.services.syncthing;
in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
  };

  age.secrets.syncthing = {
    file = ../../secrets/syncthing.json.age;
    owner = cfg.user;
    group = cfg.group;
    mode = "0400";
  };

  systemd.services.syncthing.preStart = updateConfig cfg.configDir cfg.dataDir config.age.secrets.syncthing.path;

  modules.tmpfs-as-root.persistentDirs = [ cfg.dataDir ];

  networking.firewall.interfaces.lanbr0.allowedTCPPorts = [ 8384 ];
}

