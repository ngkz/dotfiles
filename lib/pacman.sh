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

__expand_group() {
    while (( $# > 0 )); do
        local packages
        if packages=$(pacman -Sgq "$1"); then
            #package group
            echo "$packages"
        else
            #not package group
            echo "$1"
        fi
        shift
    done
}

__filter_not_installed() {
    local package
    while IFS= read -r package; do
        if ! pacman -Qi "$package" >/dev/null 2>&1; then
            echo "$package"
        fi
    done
}

__pacman_install_impl() {
    _needs_exec "pacman" || return 1

    if (( $# == 0 )); then
        _failure_reason "no package specified"
        return 1
    fi

    local package
    local to_install=()

    while IFS= read -r package; do
        to_install+=("$package")
    done < <(__expand_group "$@" |  __filter_not_installed)

    if (( ${#to_install[@]} > 0 )); then
        changed=1
        if ! is_dry_run; then
            _hide_progress
            pacman -S --needed --noconfirm "${to_install[@]}" || return 1
        fi
    fi

    return 0
}

__pacman_update_impl() {
    _needs_exec "pacman" || return 1

    if is_dry_run; then
        _failure_reason "this action doesn't support --dry-run"
        return 1
    fi

    local db_state_old db_state_new
    db_state_old=$(ls -l /var/lib/pacman/sync/*.db)
    pacman -Sy >/dev/null || return 1
    db_state_new=$(ls -l /var/lib/pacman/sync/*.db) || return 1
    if [[ $db_state_old != "$db_state_new" ]]; then
        changed=1
    fi
}

_define pacman_install __pacman_install_impl || exit 1
_define pacman_update __pacman_update_impl || exit 1
