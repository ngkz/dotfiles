#!@python3@/bin/python
import json
import os

iface = os.environ["IFACE"]
admstate = os.environ["AdministrativeState"]
ifjson = json.loads(os.environ["json"])

if iface == "wan_hgw" and admstate == "configured":
    conf = open("/etc/dnsmasq.d/10-dhcp.conf", "w")

    for ip in ifjson["DNS"]:
        print(f"server={ip}", file=conf)
        print(f"update-dnsmasq: dns={ip}")

    for ip in ifjson["NTP"]:
        if ":" in ip:
            print(f"dhcp-option=option6:ntp-server,[{ip}]", file=conf)
        else:
            print(f"dhcp-option=option:ntp-server,{ip}", file=conf)
        print(f"update-dnsmasq: ntp={ip}")

    for ip in ifjson["SIP"]:
        if ":" in ip:
            print(f"dhcp-option=option6:sip-server,[{ip}]", file=conf)
        else:
            print(f"dhcp-option=option:sip-server,{ip}", file=conf)
        print(f"update-dnsmasq: sip={ip}")

    conf.close()

    os.system("@systemd@/bin/systemctl restart dnsmasq")
