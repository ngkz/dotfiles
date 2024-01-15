#!@bash@/bin/bash
set -euo pipefail

export PATH=@path@

out=$HOME/docs/all/org
declare -A cals=(
    [ctftime]="https://calendar.google.com/calendar/ical/ctftime%40gmail.com/public/basic.ics"
)
life=$((24 * 60 * 60))

mkdir -p "$out"

work=$(mktemp -d)
trap 'rm -rf $work' EXIT

for key in "${!cals[@]}"; do
    org=$out/${key}.org
    ics=$work/${key}.ics
    url=${cals[$key]}
    if [[ -e "$org" ]] && [[ "$(($(stat -c %Y "$org") + life))" -gt "$(date +%s)" ]]; then
        echo "${key}.org ($url) is up to date"
        continue
    fi
    echo "updating ${key}.org ($url)"
    curl -Lo "$ics" "$url"
    @ical2org@ <"$ics" >"$org"
done
