{ config, pkgs, lib, ... }:
let
  cfg = config.modules.ccache;
in
{
  options.modules.ccache.packagePaths = lib.mkOption {
    type = lib.types.listOf (lib.types.listOf lib.types.str);
    default = [ ];
    description = "package paths to be compiled using ccache";
  };

  config = {
    programs.ccache = {
      enable = true;
      cacheDir = "/nix/persist/var/cache/ccache";
    };

    nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];

    systemd.tmpfiles.rules = [
      "d /nix/tmp 1775 root root 1d"
      "L /nix/persist/var/cache/ccache/ccache.conf - - - - ${./ccache.conf}"
    ];

    modules.tmpfs-as-root.persistentDirs = [
      "/var/cache/ccache"
    ];

    modules.ccache.packagePaths = [
      [ "ngkz" "fcitx5-mozc-ut" ]
      [ "ngkz" "sway-im-unwrapped" ]
    ];

    # apply after other overlays
    nixpkgs.overlays = lib.mkAfter [
      (final: prev:
        let
          mkCCacheWrapper = cc: final.ccacheWrapper.override {
            inherit cc;
            extraConfig = ''
              export CCACHE_COMPRESS=1
              export CCACHE_DIR="${config.programs.ccache.cacheDir}"
              export CCACHE_UMASK=007
              export CCACHE_BASEDIR=$NIX_BUILD_TOP
              # XXX workaround for nixpkgs #109033
              args=("$@")
              for ((i=0; i<"''${#args[@]}"; i++)); do
                case ''${args[i]} in
                  -frandom-seed=*) unset args[i]; break;;
                esac
              done
              set -- "''${args[@]}"
              [ -d "$CCACHE_DIR" ] || exec ${cc}/bin/$(basename "$0") "$@"
            '';
          };

          ccacheStdenv = final.overrideCC final.stdenv (mkCCacheWrapper final.stdenv.cc);
          ccacheClangStdenv = final.overrideCC final.stdenv ((mkCCacheWrapper final.clang).overrideAttrs (
            finalAttrs: previousAttrs: {
              # XXX workaround for nkxpkgs #119779
              installPhase = builtins.replaceStrings [ "use_response_file_by_default=1" ] [ "use_response_file_by_default=0" ] previousAttrs.installPhase;
            }
          ));
        in
        lib.ngkz.overlayPaths prev cfg.packagePaths (
          pkg: pkg.override (
            old: (
              if old ? stdenv then {
                stdenv = builtins.trace "with ccache: ${pkg.name}" ccacheStdenv;
              } else { }
            ) // (
              if old ? clangStdenv then {
                clangStdenv = builtins.trace "with ccache: ${pkg.name}" ccacheClangStdenv;
              } else { }
            )
          )
        )
      )
    ];
  };
}
