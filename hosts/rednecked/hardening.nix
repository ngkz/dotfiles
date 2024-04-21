{ inputs, lib, pkgs, ... }:
let
  inherit (inputs) nixpkgs;
in
{
  imports = [
    "${nixpkgs}/nixos/modules/profiles/hardened.nix"
  ];

  # this is fucking annoying
  security.lockKernelModules = false;

  # additional hardening
  security.allowSimultaneousMultithreading = true;
  services.dbus.apparmor = "enabled";

  # XXX workaround for https://github.com/NixOS/nixpkgs/pull/301858
  boot.kernelPackages =
    let
      inherit (pkgs) stdenv fetchurl;
      kernelPatches = {
        hardened =
          let
            mkPatch = kernelVersion:
              { version, sha256, patch }:
              let src = patch;
              in {
                name = lib.removeSuffix ".patch" src.name;
                patch = fetchurl (lib.filterAttrs (k: v: k != "extra") src);
                extra = src.extra;
                inherit version sha256;
              };
            patches = lib.importJSON ./hardened-patches.json;
          in
          lib.mapAttrs mkPatch patches;
      };
      hardenedKernelFor = kernel': overrides:
        let
          kernel = kernel'.override overrides;
          version = kernelPatches.hardened.${kernel.meta.branch}.version;
          major = lib.versions.major version;
          sha256 = kernelPatches.hardened.${kernel.meta.branch}.sha256;
          modDirVersion' = builtins.replaceStrings [ kernel.version ] [ version ]
            kernel.modDirVersion;
        in
        kernel.override {
          structuredExtraConfig = import
            "${nixpkgs}/pkgs/os-specific/linux/kernel/hardened/config.nix"
            {
              inherit stdenv lib version;
            };
          argsOverride = {
            version = lib.warnIf (kernel.version != version) "hardened kernel ${version} is old" version;
            modDirVersion = modDirVersion'
              + kernelPatches.hardened.${kernel.meta.branch}.extra;
            src = fetchurl {
              url =
                "mirror://kernel/linux/kernel/v${major}.x/linux-${version}.tar.xz";
              inherit sha256;
            };
            extraMeta = { broken = kernel.meta.broken; };
          };
          kernelPatches = kernel.kernelPatches
            ++ [ kernelPatches.hardened.${kernel.meta.branch} ];
          isHardened = true;
        };
      hardenedPackagesFor = kernel: overrides:
        pkgs.linuxPackagesFor (hardenedKernelFor kernel overrides);
    in
    hardenedPackagesFor pkgs.linux { };
}
