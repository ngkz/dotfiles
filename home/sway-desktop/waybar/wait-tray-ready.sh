#!@bash@/bin/bash
set -euo pipefail

PATH=@coreutils@/bin:@gnugrep@/bin:@dbus@/bin

while :; do
    if dbus-send --print-reply=literal --session --dest=org.kde.StatusNotifierWatcher /StatusNotifierWatcher org.freedesktop.DBus.Properties.Get string:org.kde.StatusNotifierWatcher string:IsStatusNotifierHostRegistered 2>/dev/null | grep true; then
        break
    fi
    sleep 1
done
