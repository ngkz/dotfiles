{ stdenvNoCC, fetchFromGitHub, ghidra }:
stdenvNoCC.mkDerivation {
  pname = "avr-ghidra-helpers";
  version = "unstable-2019-03-12";

  src = fetchFromGitHub {
    owner = "ahroach";
    repo = "avr_ghidra_helpers";
    rev = "a98c18b2ec627a6a2e16df360f98ce59a00eb187";
    hash = "sha256-JaunZPpFrTD4GX+uRTTOvJ/WBXQqWGWAL/6kCwTfa24=";
  };

  phases = "unpackPhase installPhase";

  installPhase = ''
    install -vD $src/atmega328.pspec $out/lib/ghidra/Ghidra/Processors/Atmel/data/languages/atmega328.pspec
    install -vD ${./avr8.ldefs} $out/lib/ghidra/Ghidra/Processors/Atmel/data/languages/avr8.ldefs
  '';
}
