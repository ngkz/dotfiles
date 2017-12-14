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

__patch_impl() {
    _needs_exec "patch" || return 1
    _parse_action_args origfile patchfile -- "$@" || return 1

    command patch -R -f --dry-run "${_args[origfile]}" "${_args[patchfile]}" \
            >/dev/null 2>&1
    case "$?" in
        0) return 0 ;;
        1) #changed
           ;;
        *) #trouble
           return 1
           ;;
    esac

    _flag_changed

    if ! is_dry_run; then
        command patch --batch --quiet --reject-file=- \
                    "${_args[origfile]}" "${_args[patchfile]}" || return 1
    fi
    return 0
}

#usage: patch ORIGINAL_FILE PATCH_FILE
_define patch __patch_impl || exit 1
