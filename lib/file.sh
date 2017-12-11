#!/bin/bash
readonly _COLOR_FAILED=$(tput setaf 1) || exit 1
readonly _COLOR_GREEN=$(tput setaf 2) || exit 1
readonly _COLOR_CHANGED=$(tput setaf 3) || exit 1
readonly _COLOR_RESET=$(tput sgr0) || exit 1
readonly _ERASE_TO_EOL=$(tput el) || exit 1

_update_cols() {
    _cols=$(tput cols)
}

_set_column() {
    tput hpa "$1"
}

#presents a prompt and gets a yes/no answer (no is default)
_noyes() {
    local prompt=${1:-"Fix inconsistency? "}

    if (( _yes )); then
        echo "$prompt [y/N]"
        return 0
    fi

    #clear stdin buffer
    [ -t 0 ] && while read -r -t 0; do read -r; done

    while :; do
        #use stderr so questions are always displayed when redirecting output.
        echo -n "$prompt [y/N] " >&2

        local input
        read -r input || return 1

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

_update_cols || exit 1
trap '_update_cols' WINCH

#
file() {
    echo -n $'\r'"$_script_name: file $* $_ERASE_TO_EOL"

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
        echo "Not enough arguments" >&2
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

    if (( changed )) && _noyes; then
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
    fi

    if ! _set_column "$((_cols - 10))"; then
        echo "[ ${_COLOR_FAILED}FAILED${_COLOR_RESET} ]"
        echo "Can't set horizontal position" >&2
        exit 1
    fi

    echo -n "[   ${_COLOR_GREEN}OK${_COLOR_RESET}   ]"
    (( _verbose )) && echo
    _changed=0
    return 0
}
