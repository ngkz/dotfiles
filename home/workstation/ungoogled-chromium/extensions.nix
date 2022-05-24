{ pkgs, lib, ... }:
let
  inherit (builtins) readFile fetchurl toPath hashString;
  inherit (lib) versions;
  inherit (pkgs) runCommandLocal runCommand fetchzip ungoogled-chromium;
in
{
  storeExtension = { id, sha256, version }:
    let
      browserVersion = (versions.major ungoogled-chromium.version);
    in
    {
      inherit id;
      crxPath = fetchurl {
        url =
          "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=${browserVersion}&x=id%3D${id}%26installsource%3Dondemand%26uc";
        name = "${id}.crx"; inherit sha256;
      };
      inherit version;
    };

  zipExtension = { name, version, url, sha256, root ? null }:
    let
      # generate deterministic key from extension name
      key = runCommandLocal "${name}.pem"
        {
          nativeBuildInputs = with pkgs; [ gnutls openssl ];
        } ''
        certtool --generate-privkey --pkcs8 --key-type=rsa --empty-password --bits=2048 --seed=${hashString "sha256" name} --provable | openssl pkcs8 -out $out -passin pass:
      '';

      pubkey = readFile (runCommandLocal "${name}-pubkey"
        {
          nativeBuildInputs = [ pkgs.openssl ];
          inherit key;
        } ''
        openssl rsa -in $key -pubout -outform DER | base64 -w0 > $out
      '');

      id = readFile (runCommandLocal "${name}-id" { inherit pubkey; } ''
        echo $pubkey | base64 -d | sha256sum | head -c32 | tr '0-9a-f' 'a-p' > $out
      '');

      crx = runCommand "${name}-${version}.crx"
        {
          nativeBuildInputs = with pkgs; [ unzip my.crx ];
          src = fetchurl {
            inherit url sha256;
          };
          inherit pubkey key root;
        } ''
        cd "$(mktemp -d)"
        mkdir extension
        cd extension
        unzip "$src"
        if [[ -z "$root" ]]; then
          if [[ -e manifest.json ]]; then
            # not wrapped in a directory
            cd ..
          fi
          crx pack * -p $key
        else
          crx pack "$root" -p $key
        fi
        mv *.crx $out
      '';
    in
    {
      inherit id version;
      crxPath = toPath crx;
    };
}
