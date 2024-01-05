{ pkgs, ... }:
let
  inherit (builtins) toJSON elem attrValues;
  inherit (pkgs.lib.attrsets) mapAttrsToList mapAttrs' filterAttrs;
  inherit (pkgs.lib) escapeShellArg concatStringsSep;

  syncthing = "${pkgs.syncthing}/bin/syncthing";
  jq = "${pkgs.jq}/bin/jq";
  xq = "${pkgs.python3Packages.yq}/bin/xq";

  guiUser = "user";

  pcs = [ "peregrine" "noguchi-pc" "rednecked" ];
  all = [ "peregrine" "noguchi-pc" "barbet" "rednecked" ];
  personal = [ "peregrine" "barbet" "rednecked" ];
  personal-pcs = [ "peregrine" "rednecked" ];

  folders = storage: {
    "~/docs" = {
      id = "docs";
      path = "${storage}/docs";
      devices = pcs;
      ignore = ''
        /all
      '';
    };
    "~/docs/all" = {
      id = "docs-all";
      path = "${storage}/docs/all";
      devices = all;
    };
    "~/music" = {
      id = "music";
      path = "${storage}/music";
      devices = personal;
    };
    "~/pics" = {
      id = "pics";
      path = "${storage}/pics";
      devices = personal-pcs;
      ignore = ''
        /phone
        /phone-dcim
      '';
    };
    "~/pics/phone" = {
      id = "pics-phone";
      path = "${storage}/pics/phone";
      devices = personal;
    };
    "~/pics/phone-dcim" = {
      id = "pics-phone-dcim";
      path = "${storage}/pics/phone-dcim";
      devices = personal;
    };
    "~/videos" = {
      id = "videos";
      path = "${storage}/videos";
      devices = personal-pcs;
      ignore = ''
        /phone
      '';
    };
    "~/videos/phone" = {
      id = "videos-phone";
      path = "${storage}/videos/phone";
      devices = personal;
    };
    "~/projects" = {
      id = "projects";
      path = "${storage}/projects";
      devices = pcs;
    };
    "~/work" = {
      id = "work";
      path = "${storage}/work";
      devices = pcs;
    };
    "~/misc" = {
      id = "misc";
      path = "${storage}/misc";
      devices = pcs;
      ignore = ''
        /all
      '';
    };
    "~/misc/all" = {
      id = "misc-all";
      path = "${storage}/misc/all";
      devices = all;
    };
  };

  devices = {
    noguchi-pc = { };
    barbet = {
      compression = "always";
    };
    peregrine = { };
    rednecked = { };
  };

  deviceFolders = hostname: storage: filterAttrs (_: v: elem hostname v.devices) (folders storage);

  foldersJSON = hostname: storage: mapAttrsToList
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
    (deviceFolders hostname storage);

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
in
{
  generateSyncthingConfigUpdateScript = { configDir, storage, secrets, hostname }: ''
    set -euo pipefail

    config=${escapeShellArg configDir}/config.xml
    secrets=${escapeShellArg secrets}
    foldersJSON='${toJSON (foldersJSON hostname storage)}'
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
                      '.configuration.gui.user = ${toJSON guiUser} |
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
      (attrValues (deviceFolders hostname storage))
    )}
  '';
}
