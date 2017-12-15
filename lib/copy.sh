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

__copy_impl() {
    _needs_exec rsync || return 1
    _parse_action_args --chown: --chmod: --delete --checksum src dest -- "$@" || return 1

    local flags=(--recursive --links --times --executability)
    [[ ${_args[chown]} != "" ]] && flags+=("--owner" "--group" "--chown=${_args[chown]}")
    [[ ${_args[chmod]} != "" ]] && flags+=("--perms" "--chmod=${_args[chmod]}")

    local difference
    difference=$(rsync "${flags[@]}" --dry-run --itemize-changes \
                    "${_args[src]}" "${_args[dest]}") || return 1
    if [[ -n $difference ]]; then
        _flag_changed
        if ! is_dry_run; then
            rsync "${flags[@]}" --quiet "${_args[src]}" "${_args[dest]}" || return 1
        fi
    fi

    return 0
}

_define copy __copy_impl
