#!/usr/bin/env bats
# vim: ft=sh
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

work="$BATS_TMPDIR/work"
install="$BATS_TEST_DIRNAME/../install"

setup() {
    mkdir "$work"
    echo "link target $(printf %q "$work/link_name")" >"$work/test.df.sh"
}

teardown() {
    rm -rf "$work"
}

@test "link: dry run" {
    run "$install" --dry-run "$work/test"
    (( status == 0 ))
    pat='^\[CHANGED \] test: '
    [[ $output =~ $pat ]]
    [[ ! -h "$work/link_name" ]]
}

@test "link: not exists" {
    run "$install" "$work/test"
    (( status == 0 ))
    pat='^\[CHANGED \] test: '
    [[ $output =~ $pat ]]
    [[ $(readlink "$work/link_name") = "target" ]]
}

@test "link: different target" {
    ln -sf wrong "$work/link_name"
    run "$install" "$work/test"
    (( status == 0 ))
    pat='^\[CHANGED \] test: '
    [[ $output =~ $pat ]]
    [[ $(readlink "$work/link_name") = "target" ]]
}

@test "link: satisfied" {
    ln -sf target "$work/link_name"
    run "$install" "$work/test"
    (( status == 0 ))
    pat='^\[   OK   \] test: '
    [[ $output =~ $pat ]]
    [[ $(readlink "$work/link_name") = "target" ]]
}
