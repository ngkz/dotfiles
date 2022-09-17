{ pkgs, ... }:
let
  inherit (builtins) hashString;
  inherit (pkgs) stdenv;
in
{
  # Based on:
  # https://github.com/NixOS/nixpkgs/pull/98014/files
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=chromium-extension-ublock-origin
  buildChromiumExtension =
    args @ { pname
    , name ? "${args.pname}-${args.version}"
    , namePrefix ? "chromium-extension-"
    , src ? ""
    , unpackPhase ? ""
    , configurePhase ? ""
    , buildPhase ? ""
    , installPhase ? null
    , nativeBuildInputs ? [ ]
    , ...
    }:
    let
      prefixedName = namePrefix + pname;
    in
    stdenv.mkDerivation (args // {
      name = namePrefix + name;

      inherit configurePhase buildPhase;

      nativeBuildInputs = with pkgs; [ gnutls openssl ngkz.crx jq ] ++ nativeBuildInputs;

      installPhase = if installPhase != null then installPhase else ''
        runHook preInstall

        # generate deterministic key from package name
        key=$(mktemp -t XXXXXXXX.pem)
        certtool --generate-privkey --pkcs8 --key-type=rsa --empty-password --sec-param=low --seed=${hashString "sha256" pname} --provable | openssl pkcs8 -out "$key" -passin pass:
        pubkey=$(openssl rsa -in $key -pubout -outform DER | base64 -w0)
        id=$(echo $pubkey | base64 -d | sha256sum | head -c32 | tr '0-9a-f' 'a-p')

        jq --ascii-output --arg key "$pubkey" '. + {key: $key}' manifest.json > manifest.json.new
        mv manifest.json.new manifest.json

        mkdir -p "$out/share/${prefixedName}"
        crx pack . -o "$out/share/${prefixedName}/${name}.crx" -p "$key"
        mkdir -p "$out/share/chromium/extensions"
        cat <<EOF >"$out/share/chromium/extensions/$id.json"
        {
          "external_crx": "$out/share/${prefixedName}/${name}.crx",
          "external_version": "${args.version}"
        }
        EOF

        runHook postInstall
      '';

      doInstallCheck = true;
      installCheckPhase = ''
        test -e "$out/share/${prefixedName}/${name}.crx" || (echo crx build failed && exit 1)
      '';
    });
}
