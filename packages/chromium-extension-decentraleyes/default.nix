{ pkgs, ... }:
let
  inherit (builtins) hashString;
  inherit (pkgs) stdenv fetchurl;
  id = "ldpochfccmkkmhdbclfhpagapcfdljkj";
in
stdenv.mkDerivation rec {
  pname = "chromium-extension-decentraleyes";
  version = "2.0.17";
  src = fetchurl {
    url = "https://git.synz.io/Synzvato/decentraleyes/uploads/c6483673bef7c90acb552b66111a3c76/Decentraleyes.v2.0.17-chromium.crx";
    sha256 = "0r7bip4yp3ybcxbm20x89qjhd346pz3b9bkalkjrgwx7q3namzgm";
  };

  phases = "installPhase";

  installPhase = ''
    install -Dm644 $src "$out/share/${pname}/decentraleyes-${version}.crx"
    mkdir -p "$out/share/chromium/extensions"
    cat <<EOF >"$out/share/chromium/extensions/${id}.json"
    {
      "external_crx": "$out/share/${pname}/decentraleyes-${version}.crx",
      "external_version": "${version}"
    }
    EOF
  '';
}
