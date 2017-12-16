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

__systemctl_impl() {
    _needs_exec systemctl || return 1
    _parse_action_args command name -- "$@" || return 1

    # shellcheck disable=SC2154
    case "${_args[command]}" in
        enable)
            if ! command systemctl is-enabled "${_args[name]}" >/dev/null 2>&1; then
                _flag_changed
                if ! is_dry_run; then
                    command systemctl enable "${_args[name]}" >/dev/null || return 1
                fi
            fi
            return 0
            ;;
        *)
            #TODO
            _failure_reason "invalid command"
            return 1
            ;;
    esac
}

_define systemctl __systemctl_impl
