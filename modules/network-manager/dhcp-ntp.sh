#!@bash@/bin/bash
set -euo pipefail

export PATH=/empty
for i in @path@; do PATH=$PATH:$i/bin; done

if [[ ! -v CONNECTION_UUID ]]; then
    exit 0
fi

interface=$1
action=$2
timesyncd_conf=/etc/systemd/timesyncd.conf.d/dhcp-$CONNECTION_UUID.conf

case "$action" in
    up|vpn-up|dhcp4-change|dhcp6-change)
        if [[ ! -v DHCP6_DHCP6_NTP_SERVERS ]] && [[ ! -v DHCP4_NTP_SERVERS ]]; then
            exit 0
        fi

        mkdir -p "$(dirname "$timesyncd_conf")"

        servers="${DHCP4_NTP_SERVERS:-} ${DHCP6_DHCP6_NTP_SERVERS:-}"

        cat <<EOS >"$timesyncd_conf"
[Time]
NTP=
NTP=$servers
EOS

        if systemctl is-active -q systemd-timesyncd.service; then
            systemctl restart systemd-timesyncd.service
        fi

        logger -t 10-dhcp-ntp "action=$action connection=$CONNECTION_UUID servers=$servers"
        ;;
    down)
        rm -f "$timesyncd_conf"

        if systemctl is-active -q systemd-timesyncd.service; then
            systemctl restart systemd-timesyncd.service
        fi

        logger -t 10-dhcp-ntp "action=$action connection=$CONNECTION_UUID"
        ;;
esac
