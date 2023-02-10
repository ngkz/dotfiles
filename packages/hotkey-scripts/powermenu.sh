#!@bash@/bin/bash

set -euo pipefail

PATH=@path@

if [[ "$#" -lt 1 || "$1" != "greeter" ]]; then
    exec nwgbar -t @template-desktop@
else
    exec nwgbar -t @template-greeter@
fi
