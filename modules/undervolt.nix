{ pkgs, ... }:
let
  inherit (builtins) toString floor;

  cpu = -120;
  gpu = -80;
  cpuCache = -80;
  gpuUnslice = -80;
  systemAgent = -30;

  pl1 = 65;
  pl1TimeWindow = 28;
  pl2 = 65;
  pl2TimeWindow = 0.00244;

  tjoffset = -3;
in
{
  systemd.services.undervolt =
    let

      rdmsr = "${pkgs.msr-tools}/bin/rdmsr";
      wrmsr = "${pkgs.msr-tools}/bin/wrmsr";
      msrVoltage = "0x150";
      msrTemp = "0x1a2";
      round = v: floor (v + 0.5);
      pl1uw = toString (round (pl1 * 1000000));
      pl1twus = toString (round (pl1TimeWindow * 1000000));
      pl2uw = toString (round (pl2 * 1000000));
      pl2twus = toString (round (pl2TimeWindow * 1000000));

      # https://github.com/mihic/linux-intel-undervolt
      script = pkgs.writeShellScript "undervolt" ''
        set -euo pipefail

        # XXX bashism
        # undervolt
        uv() {
          # uv PLANE VOLTAGE
          offset=$(( 0xffe00000 & (((($2 * 10240 - 5) / 10000) & 0xfff) << 21) ))
          ${wrmsr} ${msrVoltage} 0x80000''${1}11$(printf %08x $offset)
        }
        uv 0 ${toString cpu}
        uv 1 ${toString gpu}
        uv 2 ${toString cpuCache}
        uv 3 ${toString gpuUnslice}
        uv 4 ${toString systemAgent}

        # tjoffset
        tjoffset=${toString tjoffset}
        ${wrmsr} ${msrTemp} $(( ($(${rdmsr} -u ${msrTemp}) & 0xffffffffc0ffffff) | ((tjoffset > 0 ? 0 : (-tjoffset > 0x3f ? 0x3f : -tjoffset)) << 24) ))

        # power limit
        # MSR
        # PL1
        echo ${pl1uw} > /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw
        echo ${pl1twus} > /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/constraint_0_time_window_us
        # PL2
        echo ${pl2uw} > /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/constraint_1_power_limit_uw
        echo ${pl2twus} > /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/constraint_1_time_window_us

        # MCHBAR
        # PL1
        echo ${pl1uw} > /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_0_power_limit_uw
        echo ${pl1twus} > /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_0_time_window_us
        # PL2
        echo ${pl2uw} > /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_1_power_limit_uw
        echo ${pl2twus} > /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_1_time_window_us
      '';
    in
    {
      description = "Intel Undervolting Service";

      # Apply undervolt on boot, nixos generation switch and resume
      wantedBy = [ "multi-user.target" "post-resume.target" ];
      after = [ "post-resume.target" ]; # Not sure why but it won't work without this

      serviceConfig = {
        Type = "oneshot";
        Restart = "no";
        ExecStart = script;
      };
    };

  boot.kernelParams = [
    # Kernel 5.9 spams warnings whenever userspace writes to CPU MSRs.
    # See https://github.com/erpalma/throttled/issues/215
    "msr.allow_writes=on"
  ];
}
