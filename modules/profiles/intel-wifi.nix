{ ... }:
{
  # power saving
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=1 uapsd_disable=0
    options iwlmvm power_scheme=3
  '';
}
