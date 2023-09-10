#!@python3@/bin/python
import json
import os

iface = os.environ["IFACE"]
admstate = os.environ["AdministrativeState"]
ifjson = json.loads(os.environ["json"])

if iface == "wan_hgw" and admstate == "configured":
    conf = open("/etc/chrony.d/10-networkd-dhcp.conf", "w")

    for ip in ifjson["NTP"]:
        print(f"server {ip} iburst", file=conf)
        print(f"update-chrony: ntp={ip}")

    conf.close()

    os.system("@systemd@/bin/systemctl restart chronyd")
