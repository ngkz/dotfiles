#!@bash@/bin/bash
# This script is based on grimshot:
# https://github.com/swaywm/sway/blob/9e879242fd1f1230d34337984cca565d84b932bb/contrib/grimshot
#
# grimshot license:
# Copyright (c) 2016-2017 Drew DeVault

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -euo pipefail

PATH=@wofi@/bin:@coreutils@/bin:@grim@/bin:@slurp@/bin:@wlClipboard@/bin:@xdgUserDirs@/bin:@swappy@/bin:@sway@/bin:@jq@/bin:@libnotify@/bin:@imv@/bin

choice=$(wofi --dmenu -i -p "Select area" --cache-file /dev/null <<EOS
All screens
Active screen
Active window
Selection
EOS
)

tmp=$(mktemp --suffix=.png)

case "$choice" in
"All screens")
  grim "$tmp"
  ;;
"Active screen")
  output=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused)' | jq -r '.name')
  grim -o "$output" "$tmp"
  ;;
"Active window")
  focused=$(swaymsg -t get_tree | jq -r 'recurse(.nodes[]?, .floating_nodes[]?) | select(.focused)')
  geom=$(echo "$focused" | jq -r '.rect | "\(.x),\(.y) \(.width)x\(.height)"')
  grim -g "$geom" "$tmp"
  ;;
Selection)
  geom=$(slurp -d)
  grim -g "$geom" "$tmp"
  ;;
esac

choice=$(wofi --dmenu -i -p "Screenshot taken" --cache-file /dev/null <<EOS
Save
Copy
Edit
Discard
EOS
)

case "$choice" in
Save)
  out=$(xdg-user-dir PICTURES)/$(date +'%Y/%m/%d/Screenshot_%Y-%m-%d_%H:%M:%S.png')
  mkdir -p "$(dirname "$out")"
  cp "$tmp" "$out"
  if [ "$(notify-send -u low -e -A "show=Show" "Screenshot taken" "$out")" = show ]; then
    imv "$out"
  fi
  ;;
Copy)
  wl-copy --type image/png < "$tmp"
  notify-send -u low -e "Screenshot taken" "copied to clipboard"
  ;;
Edit)
  swappy -f "$tmp"
  ;;
esac

rm -f "$tmp"
