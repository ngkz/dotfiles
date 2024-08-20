{ pkgs, ... }:
let
  inherit (builtins) toJSON elem attrValues;
  inherit (pkgs.lib.attrsets) mapAttrsToList mapAttrs' filterAttrs;
  inherit (pkgs.lib) escapeShellArg concatStringsSep optionalString;
  inherit (pkgs.lib.strings) removeSuffix;

  syncthing = "${pkgs.syncthing}/bin/syncthing";
  jq = "${pkgs.jq}/bin/jq";
  xq = "${pkgs.python3Packages.yq}/bin/xq";
  mkdir = "${pkgs.coreutils}/bin/mkdir";
  rm = "${pkgs.coreutils}/bin/rm";

  guiUser = "user";

  pcs = [ "peregrine" "rednecked" ];
  all = [ "peregrine" "bluejay" "rednecked" ];
  personal = [ "peregrine" "bluejay" "rednecked" ];
  personal-pcs = [ "peregrine" "rednecked" ];

  ignoreCommon = ''
    .vagrant
  '';

  folders = storage: {
    "~/docs" = {
      id = "docs";
      path = "${storage}/docs";
      devices = pcs;
      ignore = ''
        /all
      '' + ignoreCommon;
    };
    "~/docs/all" = {
      id = "docs-all";
      path = "${storage}/docs/all";
      devices = all;
      ignore = ignoreCommon;
    };
    "~/music" = {
      id = "music";
      path = "${storage}/music";
      devices = personal;
      ignore = ignoreCommon;
    };
    "~/pics" = {
      id = "pics";
      path = "${storage}/pics";
      devices = personal-pcs;
      ignore = ''
        /phone
        /phone-dcim
      '' + ignoreCommon;
    };
    "~/pics/phone" = {
      id = "pics-phone";
      path = "${storage}/pics/phone";
      devices = personal;
      ignore = ignoreCommon;
    };
    "~/pics/phone-dcim" = {
      id = "pics-phone-dcim";
      path = "${storage}/pics/phone-dcim";
      devices = personal;
      ignore = ignoreCommon;
    };
    "~/videos" = {
      id = "videos";
      path = "${storage}/videos";
      devices = personal-pcs;
      ignore = ''
        /phone
      '' + ignoreCommon;
    };
    "~/videos/phone" = {
      id = "videos-phone";
      path = "${storage}/videos/phone";
      devices = personal;
      ignore = ignoreCommon;
    };
    "~/projects" = {
      id = "projects";
      path = "${storage}/projects";
      devices = pcs;
      ignore = ignoreCommon;
    };
    "~/work" = {
      id = "work";
      path = "${storage}/work";
      devices = pcs;
      ignore = ignoreCommon;
    };
    "~/misc" = {
      id = "misc";
      path = "${storage}/misc";
      devices = pcs;
      ignore = ''
        /all
      '' + ignoreCommon;
    };
    "~/misc/all" = {
      id = "misc-all";
      path = "${storage}/misc/all";
      devices = all;
      ignore = ignoreCommon;
    };
  };

  devices = {
    bluejay = {
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
          ignore = optionalString (fldrCfg ? ignore) (removeSuffix "\n" fldrCfg.ignore);
        in
          if ignore != "" then ''
            if [ ! -e ${eStignore} ] || [ "$(<${eStignore})" != "$(echo ${escapeShellArg ignore})" ]; then
              echo updating ${eStignore}
              ${mkdir} -p ${escapeShellArg fldrCfg.path}
              echo ${escapeShellArg ignore} >${eStignore}
            fi
          '' else ''
            if [ -e ${eStignore} ]; then
              echo removing ${eStignore}
              ${rm} ${eStignore}
            fi
          ''
      )
      (attrValues (deviceFolders hostname storage))
    )}
  '';
}
