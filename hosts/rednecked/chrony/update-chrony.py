#!@python3@/bin/python
import json
import os

iface = os.environ["IFACE"]
admstate = os.environ["AdministrativeState"]
ifjson = json.loads(os.environ["json"])

if iface == "wan_hgw" and admstate == "configured" and "NTP" in ifjson:
    conf = ""

    for ip in ifjson["NTP"]:
        conf += f"server {ip} iburst\n"
        print(f"update-chrony: ntp={ip}")

    try:
        with open("/etc/chrony.d/10-networkd-dhcp.conf", "r") as f:
            oldconf = f.read()
    except FileNotFoundError:
        oldconf = ""

    if oldconf != conf:
        with open("/etc/chrony.d/10-networkd-dhcp.conf", "w") as f:
            f.write(conf)

        print("update-chrony: config updated. restarting chronyd")

        os.system("@systemd@/bin/systemctl restart chronyd")
