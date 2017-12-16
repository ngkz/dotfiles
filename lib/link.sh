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

__link_impl() {
    _parse_action_args --owner --group target link_name -- "$@" || return 1

    # shellcheck disable=SC2154
    if [[ -L "${_args[link_name]}" ]]; then
        local current_target
        current_target=$(readlink "${_args[link_name]}") || return 1
        if [[ $current_target = "${_args[target]}" ]]; then
            #OK
            return 0
        fi
    fi

    _flag_changed

    if ! is_dry_run; then
        ln -sf "${_args[target]}" "${_args[link_name]}" || return 1
    fi

    return 0
}

_define link __link_impl
