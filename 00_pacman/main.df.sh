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

pacman_install patch
pacman_install rsync

# enable multilib repo
patch /etc/pacman.conf pacman.conf.patch
# shellcheck disable=SC2154
pacman_conf_changed=$changed

copy --chown root:root --chmod 0644 mirrorlist /etc/pacman.d/mirrorlist
mirrorlist_changed=$changed

if ! is_dry_run && (( pacman_conf_changed || mirrorlist_changed )); then
    pacman_update
fi
