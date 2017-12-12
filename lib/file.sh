#!/bin/bash
# dotfiles
# Copyright (C) 2017  Kazutoshi Noguchi
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

if [[ -t 1 ]]; then
    readonly _COLOR_FAILED=$(tput setaf 1) || exit 1  #red
    readonly _COLOR_OK=$(tput setaf 2) || exit 1      #green
    readonly _COLOR_CHANGED=$(tput setaf 3) || exit 1 #yellow
    readonly _COLOR_SKIPPED=$(tput setaf 6) || exit 1    #cyan
    readonly _COLOR_RESET=$(tput sgr0) || exit 1
    readonly _ERASE_TO_EOL=$(tput el) || exit 1
else
    readonly _COLOR_FAILED=
    readonly _COLOR_OK=
    readonly _COLOR_CHANGED=
    readonly _COLOR_SKIPPED=
    readonly _COLOR_RESET=
    readonly _ERASE_TO_EOL=
fi

if [[ -t 1 ]]; then
    _update_cols() {
        _cols=$(tput cols)
    }

    _update_cols || exit 1
    trap '_update_cols' WINCH
fi

_set_column() {
    if [[ -t 1 ]]; then
        tput hpa "$1"
    fi
}

#presents a prompt and gets a yes/no answer (no is default)
_noyes() {
    local prompt=${1:-"Fix inconsistency?"}

    local fd
    if (( _yes )); then
        fd=1
    else
        #use stderr so questions are always displayed when redirecting output.
        fd=2
    fi

    while :; do
        echo -n "$prompt [y/N] " >&$fd

        if (( _yes )); then
            echo "Y" >&$fd
            return 0
        fi

        #discard unhandled input on the terminal's input buffer
        [[ -t 0 ]] && while read -r -t 0; do read -r; done

        local input
        if ! read -r input; then
            #EOF
            echo >&$fd
            return 1
        fi

        # if stdin is piped, response does not get printed out, and as a result
        # a \n is missing, resulting in broken output
        if [[ ! -t 0 ]]; then
            echo "$input" >&$fd
        fi

        if [[ $input =~ ^[Yy]([Ee][Ss])?$ ]]; then
            return 0
        elif [[ -z $input || $input =~ ^[Nn][Oo]?$ ]]; then
            return 1
        fi
    done
}

is-changed() {
    (( _changed ))
}

#
file() {
    [[ -t 1 ]] && echo -n $'\r'
    echo -n "$_script_name: file $* $_ERASE_TO_EOL"

    local action_name=file

    local temp
    if ! temp=$(getopt --name "$action_name" --longoptions "owner:,group:,mode:" -- "$action_name" "$@"); then
        if ! _set_column "$((_cols - 10))"; then
            echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
            echo "Can't set horizontal position" >&2
            exit 1
        fi

        echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
        exit 1
    fi

    eval set -- "$temp"

    local owner
    local group
    local mode
    while :; do
        case "$1" in
            --owner)
                owner="$2"
                shift 2
                ;;
            --group)
                group="$2"
                shift 2
                ;;
            --mode)
                mode="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
        esac
    done

    if (( $# != 2 )); then
        if ! _set_column "$((_cols - 10))"; then
            echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
            echo "Can't set horizontal position" >&2
            exit 1
        fi

        echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
        echo "Wrong number of arguments" >&2
        exit 1
    fi

    local src=$1
    local dest=$2

    local changed=0

    if [[ -n $owner ]]; then
        local current_owner
        if ! current_owner=$(stat --format="%U" "$dest"); then
            if ! _set_column "$((_cols - 10))"; then
                echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
                echo "Can't set horizontal position" >&2
                exit 1
            fi

            echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
            echo "stat '$2' failed." >&2
            exit 1
        fi

        if [[ $current_owner != "$owner" ]]; then
            if (( ! changed )); then
                echo
            fi
            changed=1
            echo "Different owner (current: $current_owner, desired: $owner)"
        fi
    fi

    if [[ -n $group ]]; then
        local current_group
        if ! current_group=$(stat --format="%G" "$dest"); then
            if ! _set_column "$((_cols - 10))"; then
                echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
                echo "Can't set horizontal position" >&2
                exit 1
            fi

            echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
            echo "stat '$2' failed." >&2
            exit 1
        fi

        if [[ $current_group != "$group" ]]; then
            if (( ! changed )); then
                echo
            fi
            changed=1
            echo "Different group (current: $current_group, desired: $group)"
        fi
    fi

    if [[ -n $mode ]]; then
        local current_mode
        if ! current_mode=$(stat --format="%#a" "$dest"); then
            if ! _set_column "$((_cols - 10))"; then
                echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
                echo "Can't set horizontal position" >&2
                exit 1
            fi

            echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
            echo "stat '$2' failed." >&2
            exit 1
        fi

        if (( current_mode != mode )); then
            if (( ! changed )); then
                echo
            fi
            changed=1
            echo "Different mode (current: $current_mode, desired: $mode)"
        fi
    fi

    cmp --silent "$src" "$dest"
    case "$?" in
        0)
            #no differences
            ;;
        1)
            #differences were found
            if (( ! changed )); then
                echo
            fi
            changed=1
            echo "Different file content"
            ;;
        *)
            #trouble
            if ! _set_column "$((_cols - 10))"; then
                echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
                echo "Can't set horizontal position" >&2
                exit 1
            fi

            echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
            echo "Comparing '$1' and '$2' failed." >&2
            exit 1
            ;;
    esac

    if (( changed )); then
        if _noyes; then
            if ! cp "$src" "$dest"; then
                if ! _set_column "$((_cols - 10))"; then
                    echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
                    echo "Can't set horizontal position" >&2
                    exit 1
                fi

                echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
                exit 1
            fi

            if [[ -n $owner && -n $group ]]; then
                #owner and group are specified
                if ! chown "$owner:$group" "$dest"; then
                    if ! _set_column "$((_cols - 10))"; then
                        echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
                        echo "Can't set horizontal position" >&2
                        exit 1
                    fi

                    echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
                    exit 1
                fi
            elif [[ -n $owner ]]; then
                #only owner is specified
                if ! chown "$owner" "$dest"; then
                    if ! _set_column "$((_cols - 10))"; then
                        echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
                        echo "Can't set horizontal position" >&2
                        exit 1
                    fi

                    echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
                    exit 1
                fi
            elif [[ -n $group ]]; then
                #only group is specified
                if ! chgrp "$group" "$dest"; then
                    if ! _set_column "$((_cols - 10))"; then
                        echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
                        echo "Can't set horizontal position" >&2
                        exit 1
                    fi

                    echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
                    exit 1
                fi
            fi

            if [[ -n $mode ]]; then
                if ! chmod "$mode" "$dest"; then
                    if ! _set_column "$((_cols - 10))"; then
                        echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
                        echo "Can't set horizontal position" >&2
                        exit 1
                    fi

                    echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
                    exit 1
                fi
            fi

            if ! _set_column "$((_cols - 10))"; then
                echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
                echo "Can't set horizontal position" >&2
                exit 1
            fi

            echo "[${_COLOR_CHANGED}CHANGED${_COLOR_RESET} ]"

            _changed=1
            return 0
        else
            if ! _set_column "$((_cols - 10))"; then
                echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
                echo "Can't set horizontal position" >&2
                exit 1
            fi

            echo "[${_COLOR_SKIPPED}SKIPPED${_COLOR_RESET} ]"
            if [[ ! -t 1 ]] || (( _verbose )); then
                echo
            fi

            _changed=0
            return 0
        fi
    fi

    if ! _set_column "$((_cols - 10))"; then
        echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
        echo "Can't set horizontal position" >&2
        exit 1
    fi

    echo -n "[   ${_COLOR_OK}OK${_COLOR_RESET}   ]"
    if [[ ! -t 1 ]] || (( _verbose )); then
        echo
    fi
    _changed=0
    return 0
}
