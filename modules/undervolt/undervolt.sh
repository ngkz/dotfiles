#!@bash@/bin/bash
# https://github.com/mihic/linux-intel-undervolt
set -euo pipefail

PATH=@path@

MSR_VOLTAGE=0x150
MSR_TEMP=0x1a2

uv() {
    local plane=$1
    local voltage=$2

    if [[ -z $voltage ]]; then
        return
    fi

    if (( voltage > 0 )); then
        voltage=0
    fi

    offset=$(( (((voltage * 1024 - 500) / 1000) & 0x7ff) << 1 ))
    # 80000 X 1 1 YYYYYYYY
    #       |   | |- offset
    #       |   |--- read/write
    #       |------- plane index
    wrmsr $MSR_VOLTAGE "0x80000${plane}11$(printf %03x $offset)00000"
}

tjoffset() {
    local offset=$1

    if [[ -z $offset ]]; then
        return
    fi

    if (( offset > 0 )); then
        offset=0
    fi
    offset=$(( -offset ))
    if (( offset > 0x3f )); then
        offset=$(( 0x3f ))
    fi

    wrmsr $MSR_TEMP $(( ($(rdmsr -u $MSR_TEMP) & 0xffffffffc0ffffff) | (offset << 24) ))
}

power_limit() {
    name=$1
    constraint=$2
    power=$3
    time=$4

    for rapl_device in /sys/devices/virtual/powercap/intel-rapl*/intel-rapl*:*; do
        if [[ -e $rapl_device/name ]] && [[ $(<"$rapl_device/name") = "$name" ]]; then
            for constraint_name in "$rapl_device"/constraint_*_name; do
                if [[ $(<"$constraint_name") = "$constraint" ]]; then
                    constraint_prefix=${constraint_name:0:-5}
                    if [[ -n $power ]]; then
                        echo $(( power * 1000000 )) > "${constraint_prefix}_power_limit_uw"
                    fi
                    if [[ -n $time ]]; then
                        echo "$time" > "${constraint_prefix}_time_window_us"
                    fi
                fi
            done
        fi
    done
}

uv 0 "@cpu@"
uv 1 "@gpu@"
uv 2 "@cpuCache@"
uv 3 "@gpuUnslice@"
uv 4 "@systemAgent@"

power_limit package-0 short_term "@shortTermPowerLimit@" "@shortTermPowerLimitTime@"
power_limit package-0 long_term "@longTermPowerLimit@" "@longTermPowerLimitTime@"

tjoffset "@tjoffset@"
