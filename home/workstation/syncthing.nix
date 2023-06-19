{ config, osConfig, pkgs, lib, ... }:
let
  jq = "${pkgs.jq}/bin/jq";
  xq = "${pkgs.python3Packages.yq}/bin/xq";
  syncthing = "${pkgs.syncthing}/bin/syncthing";
  syncthingCfg = "${config.xdg.configHome}/syncthing/config.xml";
  syncthingTrayCfg = "${config.xdg.configHome}/syncthingtray.ini";
  hostname = "${pkgs.inetutils}/bin/hostname";
  pgrep = "${pkgs.procps}/bin/pgrep";
  systemctl = "${pkgs.systemd}/bin/systemctl";
in
{
  # Syncthing
  services.syncthing = {
    enable = true;
    tray.enable = true;
  };
  systemd.user.services.syncthingtray.Service.Restart = "on-failure";
  systemd.user.services.syncthingtray.Service.Environment = [
    "PATH=/etc/profiles/per-user/%u/bin" # XXX Qt find plugins from PATH
  ];

  home.activation.syncthing-config =
    let
      pcs = [ "noguchi-pc" "peregrine" ];
      phones = [ "barbet" ];
      all = pcs ++ phones;
      personal = builtins.filter (x: x != "noguchi-pc") all;
      personal-pcs = builtins.filter (x: x != "noguchi-pc") pcs;

      folders = [
        {
          id = "docs";
          label = "~/docs";
          path = "${config.home.tmpfs-as-home.storage}/docs";
          devices = pcs;
          ignore = ''
            /all
          '';
        }
        {
          id = "docs-all";
          label = "~/docs/all";
          path = "${config.home.tmpfs-as-home.storage}/docs/all";
          devices = all;
        }
        {
          id = "music";
          label = "~/music";
          path = "${config.home.tmpfs-as-home.storage}/music";
          devices = personal;
        }
        {
          id = "pics";
          label = "~/pics";
          path = "${config.home.tmpfs-as-home.storage}/pics";
          devices = pcs;
          ignore = ''
            /phone
            /phone-dcim
          '';
        }
        {
          id = "pics-phone";
          label = "~/pics/phone";
          path = "${config.home.tmpfs-as-home.storage}/pics/phone";
          devices = all;
        }
        {
          id = "pics-phone-dcim";
          label = "~/pics/phone-dcim";
          path = "${config.home.tmpfs-as-home.storage}/pics/phone-dcim";
          devices = all;
        }
        {
          id = "videos";
          label = "~/videos";
          path = "${config.home.tmpfs-as-home.storage}/videos";
          devices = personal-pcs;
          ignore = ''
            /phone
          '';
        }
        {
          id = "videos-phone";
          label = "~/videos/phone";
          path = "${config.home.tmpfs-as-home.storage}/videos/phone";
          devices = personal;
        }
        {
          id = "projects";
          label = "~/projects";
          path = "${config.home.tmpfs-as-home.storage}/projects";
          devices = pcs;
        }
        {
          id = "work";
          label = "~/work";
          path = "${config.home.tmpfs-as-home.storage}/work";
          devices = pcs;
        }
        {
          id = "misc";
          label = "~/misc";
          path = "${config.home.tmpfs-as-home.storage}/misc";
          devices = pcs;
          ignore = ''
            /all
          '';
        }
        {
          id = "misc-all";
          label = "~/misc/all";
          path = "${config.home.tmpfs-as-home.storage}/misc/all";
          devices = all;
        }
      ];

      secretsFile = osConfig.age.secrets.syncthing.path;

      devices = {
        noguchi-pc = { };
        barbet = {
          compression = "always";
        };
        peregrine = { };
      };
    in
    lib.hm.dag.entryBetween [ "reloadSystemd" ] [ "linkGeneration" "tmpfs-as-home" ] ''
      # update config.xml
      needRestart=1
      if [ ! -e ${syncthingCfg} ]; then
        $DRY_RUN_CMD ${syncthing} generate --skip-port-probing >/dev/null
      fi
      if [ -e ${syncthingCfg} ]; then
        folders=$(${jq} --argjson secrets "$(<"${secretsFile}")" \
                        --arg hostname "$(${hostname})" \
                        --argjson defaults "$(${xq} ".configuration.defaults.folder" ${syncthingCfg})" '
          map(
            select(.devices|contains([$hostname])) |
            $defaults * {"device": (
              .devices |
              map({ "@id": $secrets.ids[.], "@introducedBy": "", "encryptionPassword": null })
            )} * with_entries(
              select(.key != "devices" and .key != "ignore") |
              if [.key] | inside(["id", "label", "path", "type", "rescanIntervalS", "fsWatcherEnabled", "fsWatcherDelayS", "ignorePerms", "autoNormalize"]) then
                .key = "@" + .key
              else
                .
              end
            )
          )' <<<'${builtins.toJSON folders}')
        devices=$(${jq} --argjson secrets "$(<"${secretsFile}")" \
                        --argjson defaults "$(${xq} ".configuration.defaults.device" ${syncthingCfg})" '
          to_entries|
          map(
            .value as $v |
            $defaults * { "@id": $secrets.ids[.key], "@name": .key } * (
              $v |
              with_entries(
                if [.key] | inside(["compression", "introducer", "skipIntroductionRemovals"]) then
                  .key = "@" + .key
                else
                  .
                end
              )
            )
          )' <<<'${builtins.toJSON devices}')
        newConfig=$(${xq} -x \
          --argjson secrets "$(<"${secretsFile}")" \
          --argjson devices "$devices" \
          --argjson folders "$folders" \
          '. * { "configuration": {
            "gui": (.configuration.gui + {
              "user": "user",
              "password": $secrets.password
            }),
            "device": $devices,
            "folder": $folders
          } }' \
          ${syncthingCfg}
        )
        if [ "$(${xq} -x <${syncthingCfg})" = "$newConfig" ]; then
          needRestart=
        else
          if [ -v DRY_RUN ]; then
            $DRY_RUN_CMD echo "$newConfig" ">${syncthingCfg}"
          else
            echo "$newConfig" >${syncthingCfg}
          fi
        fi
      fi
      unset newConfig
      unset folders
      unset devices

      # update stignore
      ${jq} -c --arg hostname "$(${hostname})" '.[]|select(.devices|contains([$hostname]))' <<<'${builtins.toJSON folders}' | while read -r folder_json; do
        path=$(${jq} -r '.path' <<<"$folder_json")
        if [ -v VERBOSE ]; then
          echo "writing $path/.stignore"
        fi
        $DRY_RUN_CMD mkdir -p "$path"
        if [ "$(${jq} -r '.ignore == "" or .ignore == null' <<<"$folder_json")" = true ]; then
          $DRY_RUN_CMD rm -f "$path/.stignore"
        elif [ -v DRY_RUN ]; then
          echo -e "echo $(${jq} ".ignore" <<<"$folder_json") >$path/.stignore"
        else
          ${jq} -r ".ignore" <<<"$folder_json" >"$path/.stignore"
        fi
      done
      unset path

      if [ -n "$needRestart" ]; then
        if [ -v VERBOSE ]; then
          echo restarting syncthing
        fi
        if ${pgrep} -u $(id -u) -x syncthing >/dev/null; then
          $DRY_RUN_CMD ${syncthing} cli operations restart
        fi
      fi
      unset needRestart

      # update syngthingtray.ini
      newConfig=$(sed "s/@apiKey@/$(${xq} -r ".configuration.gui.apikey" ${syncthingCfg})/g" ${./syncthingtray.ini})
      if [ ! -e ${syncthingTrayCfg} ] || [ "$(<${syncthingTrayCfg})" != "$newConfig" ]; then
        if [ -v VERBOSE ]; then
          echo updating syncthingtray config
        fi
        if [ -v DRY_RUN ]; then
          echo echo "$newConfig" ">${syncthingTrayCfg}"
        else
          echo "$newConfig" >${syncthingTrayCfg}
        fi

        if ${pgrep} -u $(id -u) syncthingtray >/dev/null; then
          if [ -v VERBOSE ]; then
            echo restarting syncthingtray
          fi
          $DRY_RUN_CMD ${systemctl} restart --user syncthingtray.service
        fi
      fi
      unset newConfig
    '';

  home.tmpfs-as-home.persistentDirs = [
    ".config/syncthing"
    ".local/share/syncthing"
  ];
}
