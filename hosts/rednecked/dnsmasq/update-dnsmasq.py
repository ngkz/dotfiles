#!@python3@/bin/python
import json
import os

iface = os.environ["IFACE"]
admstate = os.environ["AdministrativeState"]
ifjson = json.loads(os.environ["json"])

if iface == "wan_hgw" and admstate == "configured" and "DNS" in ifjson:
    conf = ""

    for ip in ifjson["DNS"]:
        conf += f"server={ip}\n"
        print(f"update-dnsmasq: dns={ip}")

    for ip in ifjson["SIP"]:
        if ":" in ip:
            conf += f"dhcp-option=option6:sip-server,[{ip}]\n"
        else:
            conf += f"dhcp-option=option:sip-server,{ip}\n"
        print(f"update-dnsmasq: sip={ip}")

    try:
        with open("/etc/dnsmasq.d/10-networkd-dhcp.conf", "r") as f:
            oldconf = f.read()
    except FileNotFoundError:
        oldconf = ""

    if oldconf != conf:
        with open("/etc/dnsmasq.d/10-networkd-dhcp.conf", "w") as f:
            f.write(conf)

        print("update-dnsmasq: config updated. restarting dnsmasq")

        os.system("@systemd@/bin/systemctl restart dnsmasq")
